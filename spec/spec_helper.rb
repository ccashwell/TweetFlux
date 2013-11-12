# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rails'
require 'capybara/rspec'
require 'vcr'
require 'webmock/rspec'

Capybara.server_port = 31337
WebMock.disable_net_connect!(allow_localhost: true)

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'

  config.around(:each) do |example|
    VCR.use_cassette('tweet_flux', record: :once, allow_playback_repeats: true, decode_compressed_response: true) do
      example.call
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/cassettes'
  config.hook_into :webmock
  config.ignore_hosts '127.0.0.1', 'localhost'
end

