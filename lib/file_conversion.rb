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

  # Get image dimensions using ImageMagick's `identify`
  # Returns a hash conforming the shape {:width => "1000", :height => "600"}
  #  (otherwise an exception is thrown)
  # Note: Exif orientation is not taken into account.
  def self.get_dimensions(file)
    output = `identify -ping -format '%w %h ' #{file}`
    if output.class != String
      raise 'System call to `identify`: '\
        "Unexpected output type: `#{output.class}` (should be `String`)"
    end
    img_x, img_y = output.split
    unless /\A\d+\z/ =~ img_x and /\A\d+\z/ =~ img_y
      raise 'System call to `identify`: '\
        "Unexpected output \"#{output}\" (should start with two numbers like this:  \"1234 876\")"
    end
    { width: img_x, height: img_y }
  end
end
