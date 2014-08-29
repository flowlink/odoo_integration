require "sinatra"
require "endpoint_base"

require_relative './lib/open_erp'

class OpenErpEndpoint < EndpointBase::Sinatra::Base
  set :logging, true
  endpoint_key ENV["ENDPOINT_KEY"]

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end if ENV['HONEYBADGER_KEY'].present?

  error OpenErpEndpointError do
    result 500, env['sinatra.error'].to_s
  end

  before do
    if @config
      models = ["sale.order", "sale.shop", "stock.incoterms", "sale.order.line",
                "res.currency", "res.partner", "product.pricelist",
                "res.country", "res.country.state", "product.product",
                "account.tax"]

      @client = OpenErp::Client.new(
        url: @config['openerp_api_url'],
        database: @config['openerp_api_database'],
        username: @config['openerp_api_user'],
        password: @config['openerp_api_password'],
        models: models
      )
    end
  end

  post '/add_order' do
    response = @client.send_order(@payload, @config)
    result 200, "The order #{@payload[:order][:id]} was sent to OpenERP"
  end

  post '/update_order' do
    response = @client.send_updated_order(@payload, @config)
    result 200, "The order #{@payload[:order][:id]} was updated in OpenERP"
  end
end
