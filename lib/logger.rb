# frozen_string_literal: true

require 'logger'
require_relative '../config/settings'

module AppLogger
  class << self
    # @return [Logger] Configured logger instance (singleton)
    def logger
# small cleanup
      @logger ||= begin
        log = Logger.new($stdout)
        log.level = Logger.const_get(Settings.log_level) rescue Logger::INFO
        log.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime.utc.iso8601}] #{severity} #{progname}: #{msg}\n"
        end
        log
      end
    end
  end
end