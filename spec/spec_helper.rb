require 'bundler'
require 'rubygems'

Bundler.require(:default, :test)

require_relative '../open_erp_endpoint.rb'
require 'spree/testing_support/controllers'

Dir["./spec/support/**/*.rb"].each { |f| require f }

Sinatra::Base.environment = 'test'

def app
  OpenErpEndpoint
end

ENV['OPENERP_URL'] ||= "http://staging.example.com"
ENV['OPENERP_DB'] ||= "db"
ENV['OPENERP_USER'] ||= "user"
ENV['OPENERP_PASS'] ||= "pass"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/cassetes'
  c.hook_into :webmock

  c.filter_sensitive_data("OPENERP_URL") { URI(ENV["OPENERP_URL"]).host }
  c.filter_sensitive_data("OPENERP_DB") { ENV["OPENERP_DB"] }
  c.filter_sensitive_data("OPENERP_USER") { ENV["OPENERP_USER"] }
  c.filter_sensitive_data("OPENERP_PASS") { ENV["OPENERP_PASS"] }
end
