require "sinatra"
require "endpoint_base"

require_relative './lib/open_erp'

class OpenErpEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  before do
    if @config
      models = if request.path_info.include? "order"
                 ["sale.order", "sale.shop", "stock.incoterms", "sale.order.line",
                  "res.currency", "res.partner", "product.pricelist",
                  "res.country", "res.country.state", "product.product"]
               elsif request.path_info.include? "shipment"
                 ["sale.order"]
               else
                 ["product.product"]
               end

      @client = OpenErp::Client.new(
        url: @config['openerp_api_url'],
        database: @config['openerp_api_database'],
        username: @config['openerp_api_user'],
        password: @config['openerp_api_password'],
        models: models
      )
    end
  end

  post '/get_products' do
    begin
      products = @client.import_products
      products.each { |p| add_object 'product', p }

      if (count = products.count) > 0
        result 200, "Received #{count} #{"product".pluralize count} from OpenERP"
      else
        result 200
      end
    rescue => e
      result 500, e.message
    end
  end

  post '/add_order' do
    begin
      response = @client.send_order(@payload, @config)
      result 200, "The order #{@payload[:order][:id]} was sent to OpenERP"
    rescue => e
      result 500, e.message
    end
  end

  post '/update_order' do
    begin
      response = @client.send_updated_order(@payload, @config)
      result 200, "The order #{@payload[:order][:id]} was updated in OpenERP"
    rescue => e
      result 500, e.message
    end
  end

  post '/get_inventory' do
    begin
      stock = @client.update_stock(@payload)
      add_object 'inventory', stock

      result 200, "Inventory #{@payload[:inventory][:sku]} updated"
    rescue => e
      result 500, e.message
    end
  end

  post '/get_shipments' do
    begin
      shipments = @client.confirm_shipment
      shipments.each { |s| add_object 'shipment', s }

      result 200, 'All pending shipments from OpenERP have been marked as shipped.'
    rescue => e
      result 500, "An OpenERP Endpoint error has occured: #{e.message}"
    end
  end
end
