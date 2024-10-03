class ZencoderRequester
  def initialize(media_file, only_profiles: false)
    @media_file = media_file
    @only_profiles = only_profiles
    @media_type = @media_file.media_type.to_sym
    raise ArgumentError if @only_profiles and !@only_profiles.is_a?(Array)
  end

  def process
    unless File.exist?(@media_file.original_store_location)
      raise "Input file doesn't exist"
    end

    if Settings.zencoder_enabled
      unless Zencoder.api_key
        raise 'Zencoder API key is mandatory for submitting to Zencoder.com'
      end
      @zencoder_job = ZencoderJob.create(media_file: @media_file)
      create_zencoder_job
    else
      raise 'Zencoder is not enabled! Check your zencoder configuration!'
    end
  end

  private

  def create_zencoder_job
    @zencoder_job.update(request: request_params)

    if (response = Zencoder::Job.create(**request_params)).success?
      @zencoder_job.update(
        state: 'submitted',
        response: response.body,
        zencoder_id: response.body['id']
      )
    else
      @zencoder_job.update(
        state: 'failed',
        error: response.try(:body)
      )
      false
    end
  end

  def request_params
    params = {
      input: input_file_url,
      notifications: [notification_url]
    }

    params[:test] = Settings.zencoder_test_mode
    params.merge!(output_settings)
  end

  def output_settings
    defaults = {
      label: 'Default',
      quality: 4,
      speed: 2,
      width: width
    }
    outputs = output_profiles.map do |profile, output|
      filename = "#{@media_file.id}.profile_#{profile}.#{output[:format]}"
      output
        .merge(label: profile.to_s)
        .merge(filename: filename)
        .merge(video_thumbnails_settings(output))
    end
    defaults.merge(outputs: outputs)
  end

  def video_thumbnails_settings(output)
    return {} unless @media_type == :video and output[:thumbnails]
    conf = Settings.zencoder_video_thumbnails_defaults.to_h.deep_symbolize_keys
    { thumbnails: (conf.presence or {}).merge(prefix: @media_file.id) }
  end

  def width
    Madek::Constants::THUMBNAILS[:large].fetch(:width, 620)
  end

  def input_file_url
    base_url + media_file_path
  end

  def notification_url
    base_url + zencoder_job_notification_path
  end

  def base_url
    Settings.madek_external_base_url
  end

  def media_file_path
    "/files/#{@media_file.id}?access_token=#{@zencoder_job.access_token}"
  end

  def zencoder_job_notification_path
    "/zencoder_jobs/#{@zencoder_job.id}/notification"
  end

  def output_profiles
    settings = case @media_type
               when :audio then Settings.zencoder_audio_output_formats.to_h
               when :video then Settings.zencoder_video_output_formats.to_h
               else raise 'Unsupported media type!'
               end
    validate_configured_formats(settings)
    if @only_profiles
      validate_given_profiles(settings)
      return settings.select { |k, v| @only_profiles.include?(k.to_sym) }.as_json
    end
    settings.as_json
  end

  def validate_configured_formats(settings)
    settings.each { |k, v| raise 'missing format!' unless v[:format].present? }
  end

  def validate_given_profiles(settings)
    unless (@only_profiles - settings.keys.map(&:to_sym)).empty?
      raise 'Invalid profiles! possible values: ' + settings.keys.join(', ')
    end
  end

end
