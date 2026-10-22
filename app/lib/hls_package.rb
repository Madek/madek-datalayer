require 'cgi'
require 'fileutils'
require 'pathname'

# Writes one fMP4 HLS package next to a media file's thumbnails and keeps the
# single `hls` preview row in sync with master.m3u8.
class HlsPackage
  class InvalidPackage < StandardError; end

  HLS_PROFILES = %i[hls hls_360 hls_720 hls_1080].freeze

  def initialize(media_file)
    @media_file = media_file
  end

  def dir
    File.join(@media_file.thumbnail_store_location, 'hls')
  end

  def zip_path
    File.join(@media_file.thumbnail_store_location, 'hls.zip')
  end

  def import!(source_dir)
    parent = File.dirname(dir)
    FileUtils.mkdir_p(parent)
    tmp = "#{dir}.tmp-#{Process.pid}"
    FileUtils.rm_rf(tmp)
    FileUtils.mkdir_p(tmp)
    FileUtils.cp_r(Dir.glob(File.join(source_dir, '*')), tmp)
    rewrite_playlists!(tmp)
    validate!(tmp)

    replaced = "#{dir}.old-#{Process.pid}"
    FileUtils.rm_rf(replaced)
    FileUtils.mv(dir, replaced) if File.directory?(dir)
    FileUtils.mv(tmp, dir)
    FileUtils.rm_rf(replaced)
    FileUtils.rm_f(zip_path)
    upsert_preview!
    self
  rescue InvalidPackage
    FileUtils.rm_rf(tmp) if tmp
    raise
  end

  def renditions
    master_path = File.join(dir, 'master.m3u8')
    return [] unless File.file?(master_path)

    lines = File.read(master_path).lines.map(&:strip)
    lines.each_with_index.filter_map do |line, index|
      next unless line.start_with?('#EXT-X-STREAM-INF')

      playlist = lines[index + 1]
      next if playlist.nil? || playlist.empty? || playlist.start_with?('#')

      width, height = line.match(/RESOLUTION=(\d+)x(\d+)/)&.captures&.map(&:to_i)
      bandwidth = line[/BANDWIDTH=(\d+)/, 1]&.to_i
      {
        height: height,
        width: width,
        bandwidth: bandwidth,
        playlist: File.basename(playlist),
        media_file: media_file_name(File.join(dir, File.basename(playlist)))
      }
    end
  end

  def ensure_zip!
    return zip_path if File.file?(zip_path) && File.size(zip_path).positive?

    FileUtils.mkdir_p(File.dirname(zip_path))
    tmp = "#{zip_path}.tmp-#{Process.pid}"
    FileUtils.rm_f(tmp)
    require 'zip'
    Zip::OutputStream.open(tmp) do |out|
      Dir.glob(File.join(dir, '**', '*')).sort.each do |file|
        next unless File.file?(file)

        name = Pathname(file).relative_path_from(Pathname(dir)).to_s
        write_stored(out, name, file)
      end
    end
    FileUtils.mv(tmp, zip_path)
    zip_path
  end

  def self.append_access_token(text, token)
    return text if token.blank?

    escaped = CGI.escape(token.to_s)
    rewritten = text.gsub(/URI="([^"]+)"/) do
      %(URI="#{append_token_to_uri(::Regexp.last_match(1), escaped)}")
    end
    rewritten.each_line.map do |line|
      stripped = line.strip
      if stripped.empty? || stripped.start_with?('#')
        line.end_with?("\n") ? line : "#{line}\n"
      else
        "#{append_token_to_uri(stripped, escaped)}\n"
      end
    end.join
  end

  def self.append_token_to_uri(uri, escaped_token)
    return uri if uri.blank?
    return uri if uri.match?(/[?&]accessToken=/)

    joiner = uri.include?('?') ? '&' : '?'
    "#{uri}#{joiner}accessToken=#{escaped_token}"
  end

  private

  def rewrite_playlists!(root)
    Dir.glob(File.join(root, '**', '*.m3u8')).each do |path|
      text = File.read(path)
      text = text.gsub(/URI="([^"]+)"/) do
        %(URI="#{File.basename(::Regexp.last_match(1).split('?').first)}")
      end
      lines = text.each_line.map do |line|
        stripped = line.strip
        if stripped.empty? || stripped.start_with?('#')
          line.end_with?("\n") ? line : "#{line}\n"
        else
          "#{File.basename(stripped.split('?').first)}\n"
        end
      end
      File.write(path, lines.join)
    end
  end

  def validate!(root)
    master_path = File.join(root, 'master.m3u8')
    raise InvalidPackage, 'master missing' unless nonempty_file?(master_path)

    variants = stream_playlists(File.read(master_path))
    raise InvalidPackage, 'no variants' if variants.empty?

    seen = {}
    variants.each { |name| require_playlist!(root, name, seen) }
  end

  def require_playlist!(root, name, seen)
    return if seen[name]

    seen[name] = true
    path = File.join(root, name)
    raise InvalidPackage, "missing #{name}" unless nonempty_file?(path)

    referenced_names(File.read(path)).each do |ref|
      if ref.end_with?('.m3u8')
        require_playlist!(root, ref, seen)
      else
        raise InvalidPackage, "missing #{ref}" unless nonempty_file?(File.join(root, ref))
      end
    end
  end

  def stream_playlists(master)
    lines = master.lines.map(&:strip)
    lines.each_with_index.filter_map do |line, index|
      next unless line.start_with?('#EXT-X-STREAM-INF')

      playlist = lines[index + 1]
      next if playlist.nil? || playlist.empty? || playlist.start_with?('#')

      File.basename(playlist.split('?').first)
    end
  end

  def referenced_names(text)
    names = []
    text.scan(/URI="([^"]+)"/) { names << File.basename(::Regexp.last_match(1).split('?').first) }
    text.each_line do |line|
      stripped = line.strip
      next if stripped.empty? || stripped.start_with?('#')

      names << File.basename(stripped.split('?').first)
    end
    names.uniq
  end

  def nonempty_file?(path)
    File.file?(path) && File.size(path).positive?
  end

  def media_file_name(playlist_path)
    return unless File.file?(playlist_path)

    text = File.read(playlist_path)
    mapped = text[/EXT-X-MAP:.*?URI="([^"]+)"/, 1]
    return File.basename(mapped) if mapped

    text.each_line do |line|
      stripped = line.strip
      next if stripped.empty? || stripped.start_with?('#') || stripped.end_with?('.m3u8')

      return File.basename(stripped)
    end
    nil
  end

  def largest_resolution(master)
    pairs = master.scan(/RESOLUTION=(\d+)x(\d+)/).map { |width, height| [width.to_i, height.to_i] }
    pairs.max_by { |_width, height| height } || [nil, nil]
  end

  def upsert_preview!
    width, height = largest_resolution(File.read(File.join(dir, 'master.m3u8')))
    preview = @media_file.previews.find_or_initialize_by(conversion_profile: 'hls')
    preview.assign_attributes(
      content_type: 'application/vnd.apple.mpegurl',
      media_type: 'video',
      filename: "#{@media_file.guid}/hls/master.m3u8",
      width: width,
      height: height,
      thumbnail: 'large'
    )
    preview.save!
    preview
  end

  def write_stored(out, name, file)
    # rubyzip 1.3 overwrites an entry's method with DEFLATED unless the
    # method is passed in. Stored entries keep fMP4 byte ranges intact.
    entry = Zip::Entry.new('', name)
    out.put_next_entry(entry, nil, nil, Zip::Entry::STORED)
    File.open(file, 'rb') { |io| IO.copy_stream(io, out) }
  end
end
