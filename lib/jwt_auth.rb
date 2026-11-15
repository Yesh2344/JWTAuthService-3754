# frozen_string_literal: true

require 'jwt'
require_relative '../config/settings'
require_relative 'logger'

module JWTAuth
  class << self
    # Generates a signed JWT for the given payload.
    #
    # @param payload [Hash] Custom claims (e.g., { user_id: 1 })
    # @return [String] Signed JWT
    def encode(payload)
      exp = Time.now.to_i + Settings.token_expiry
      full_payload = payload.merge(exp: exp)
      JWT.encode(full_payload, Settings.jwt_secret, 'HS256')
    rescue StandardError => e
      AppLogger.logger.error("JWT encode error: #{e.message}")
      raise
    end

    # Decodes and verifies a JWT.
    #
    # @param token [String] JWT string
    # @return [Hash] Decoded payload
    # @raise [JWT::DecodeError, JWT::ExpiredSignature] if token is invalid
    def decode(token)
      decoded = JWT.decode(token, Settings.jwt_secret, true, algorithm: 'HS256')
      decoded.first # payload is the first element
    rescue JWT::ExpiredSignature => e
      AppLogger.logger.warn("Expired token: #{e.message}")
      raise
    rescue JWT::DecodeError => e
      AppLogger.logger.warn("Invalid token: #{e.message}")
      raise
    end
  end
end