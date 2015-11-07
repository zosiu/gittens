require 'dotenv'
Dotenv.load

require 'cuba'
require 'cuba/render'
require 'json'
require 'tilt/haml'

require 'dalli'
require 'faraday-http-cache'
require 'octokit'

require_relative 'gittenizer'

class Dalli::Client
  alias_method :write, :set
  alias_method :read, :get
end

DALLI_OPTIONS = { username: ENV['MEMCACHIER_USERNAME'],
                  password: ENV['MEMCACHIER_PASSWORD'],
                  compress: true,
                  expires_in: 3600 }

DALLI_CACHE = Dalli::Client.new((ENV['MEMCACHIER_SERVERS'] || '').split(','), DALLI_OPTIONS)

OCTOKIT_STACK = Faraday::RackBuilder.new do |builder|
  # builder.response :logger
  builder.use Faraday::HttpCache, store: DALLI_CACHE, serializer: Marshal
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end

Octokit.middleware = OCTOKIT_STACK
# Octokit.auto_paginate = true

GITHUB = Octokit::Client.new client_id: ENV['GITHUB_CLIENT_ID'],
                             client_secret: ENV['GITHUB_CLIENT_SECRET']
