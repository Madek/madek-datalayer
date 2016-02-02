class ActiveSupport::Logger::SimpleFormatter
  def call(severity, time, _progname, msg)
    "[#{severity.center(5)}, #{time.iso8601}] #{msg}\n"
  end
end
