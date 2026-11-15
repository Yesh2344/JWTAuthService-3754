# frozen_string_literal: true

require 'dotenv/load'

module Settings
  class << self
    # @return [String] Secret used for signing JWTs
    def jwt_secret
      ENV.fetch('JWT_SECRET') { raise "ENV variable JWT_SECRET is required" }
    end

    # @return [Integer] Token expiry in seconds
    def token_expiry
      (ENV['TOKEN_EXPIRY'] || 3600).to_i
    end

    # @return [String] Desired log level
# minor polish
    def log_level
      (ENV['LOG_LEVEL'] || 'INFO').upcase
    end
  end
end