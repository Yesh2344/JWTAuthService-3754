# frozen_string_literal: true

require 'sinatra/base'
require_relative 'lib/jwt_auth'
require_relative 'lib/logger'

# Simple in‑memory user store (replace with DB in production)
USERS = {
  'alice' => 'password123',
  'bob'   => 'secret'
}.freeze

class JWTAuthService < Sinatra::Base
  configure do
    set :show_exceptions, false
    set :logging, nil # Disable Sinatra's default logger
  end

  before do
    content_type :json
  end

  error JWT::DecodeError do
    status 401
    { error: 'Invalid token' }.to_json
  end

  error JWT::ExpiredSignature do
    status 401
    { error: 'Token has expired' }.to_json
  end

  post '/login' do
    begin
      data = JSON.parse(request.body.read)
      username = data['username']
      password = data['password']

      halt 400, { error: 'Missing credentials' }.to_json unless username && password

      if USERS[username] == password
        token = JWTAuth.encode(user: username)
        AppLogger.logger.info("User '#{username}' authenticated successfully")
        { token: token }.to_json
      else
        AppLogger.logger.warn("Failed login attempt for user '#{username}'")
        halt 401, { error: 'Invalid username or password' }.to_json
      end
    rescue JSON::ParserError => e
      AppLogger.logger.error("JSON parse error: #{e.message}")
      halt 400, { error: 'Invalid JSON payload' }.to_json
    end
  end

  get '/protected' do
    auth_header = request.env['HTTP_AUTHORIZATION']
    halt 401, { error: 'Missing Authorization header' }.to_json unless auth_header

    token = auth_header.split(' ').last
    payload = JWTAuth.decode(token)

    AppLogger.logger.info("Protected resource accessed by #{payload['user']}")
    { message: "Hello #{payload['user']}, you accessed a protected route!" }.to_json
  end

  # Start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME
end