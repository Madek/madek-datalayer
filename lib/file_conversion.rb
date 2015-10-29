module FileConversion
  def self.convert(file, outfile, width, height)
    raise "Input file doesn't exist!" unless File.exist?(file)

    if width and height
      thumbnail_option = "-thumbnail #{width}x#{height}"
    end

    cmd = "convert '#{file}'[0] " \
          '-auto-orient ' \
          '-flatten ' \
          '-unsharp 0x.5 ' \
          "#{thumbnail_option} " \
          "'#{outfile}'"

    Rails.logger.info "CREATING THUMBNAIL `#{cmd}`"
    `#{cmd}`
  end
end
