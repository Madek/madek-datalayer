require 'spec_helper'

describe HlsPackage do
  let(:media_file) do
    create(:media_file, media_type: 'video', content_type: 'video/mp4')
  end
  let(:package) { described_class.new(media_file) }

  def write_package(dir, media_name: '360.mp4', playlist_uri: '360.mp4')
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, media_name), 'media-bytes')
    File.write(
      File.join(dir, '360.m3u8'),
      <<~M3U8
        #EXTM3U
        #EXT-X-MAP:URI="#{playlist_uri}"
        #EXTINF:6,
        #{playlist_uri}
        #EXT-X-ENDLIST
      M3U8
    )
    File.write(
      File.join(dir, 'master.m3u8'),
      <<~M3U8
        #EXTM3U
        #EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
        360.m3u8
      M3U8
    )
  end

  describe '#import!' do
    it 'rewrites absolute urls and stores a video preview' do
      source = Dir.mktmpdir
      write_package(
        source,
        playlist_uri: 'https://zencoder.example/outputs/360.mp4?token=secret'
      )
      File.write(
        File.join(source, 'master.m3u8'),
        <<~M3U8
          #EXTM3U
          #EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
          https://zencoder.example/outputs/360.m3u8
        M3U8
      )

      package.import!(source)

      master = File.read(File.join(package.dir, 'master.m3u8'))
      variant = File.read(File.join(package.dir, '360.m3u8'))
      expect(master).to include("360.m3u8\n")
      expect(master).not_to include('zencoder.example')
      expect(variant).to include('URI="360.mp4"')
      expect(variant).not_to include('token=secret')

      preview = media_file.previews.find_by(conversion_profile: 'hls')
      expect(preview.media_type).to eq 'video'
      expect(preview.content_type).to eq 'application/vnd.apple.mpegurl'
      expect(preview.width).to eq 640
      expect(preview.height).to eq 360
      expect(preview.filename).to eq "#{media_file.guid}/hls/master.m3u8"
    end

    it 'rejects a package whose media file is missing and keeps the previous one' do
      source = Dir.mktmpdir
      write_package(source)
      package.import!(source)
      preview_id = media_file.previews.find_by(conversion_profile: 'hls').id

      broken = Dir.mktmpdir
      write_package(broken, media_name: 'other.mp4', playlist_uri: '360.mp4')
      FileUtils.rm_f(File.join(broken, '360.mp4'))

      expect { package.import!(broken) }.to raise_error(HlsPackage::InvalidPackage)
      expect(File.file?(File.join(package.dir, '360.mp4'))).to be true
      expect(media_file.previews.find_by(conversion_profile: 'hls').id).to eq preview_id
    end

    it 'replaces an older package and drops the cached zip' do
      source = Dir.mktmpdir
      write_package(source)
      package.import!(source)
      FileUtils.mkdir_p(File.dirname(package.zip_path))
      File.write(package.zip_path, 'stale')

      replacement = Dir.mktmpdir
      write_package(replacement)
      File.write(
        File.join(replacement, 'master.m3u8'),
        <<~M3U8
          #EXTM3U
          #EXT-X-STREAM-INF:BANDWIDTH=3000000,RESOLUTION=1280x720
          360.m3u8
        M3U8
      )
      package.import!(replacement)

      expect(File.exist?(package.zip_path)).to be false
      expect(media_file.previews.where(conversion_profile: 'hls').count).to eq 1
      expect(media_file.previews.find_by(conversion_profile: 'hls').height).to eq 720
    end
  end

  describe '#renditions' do
    it 'lists the media file for each rung' do
      source = Dir.mktmpdir
      write_package(source)
      package.import!(source)

      expect(package.renditions).to eq [
        {
          height: 360,
          width: 640,
          bandwidth: 800_000,
          playlist: '360.m3u8',
          media_file: '360.mp4'
        }
      ]
    end
  end
end
