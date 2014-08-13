require "sinatra"
require "endpoint_base"

require_relative './lib/open_erp'

class OpenErpEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  before do
    models = if request.path_info.include? "order"
               ["sale.order", "sale.shop", "stock.incoterms", "sale.order.line",
                "res.currency", "res.partner", "product.pricelist",
                "res.country", "res.country.state", "product.product"]
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

  post '/get_products' do
    begin
      products = @client.import_products
      products.each { |p| add_object 'product', p }

      line = if (count = products.count) > 0
               "Updating #{count} #{"product".pluralize count} from OpenERP"
             else
               "No product to import found"
             end

      result 200, line
    rescue => e
      result 500, e.message
    end
  end

  post '/add_order' do
    begin
      response = @client.send_order(@payload, @config)
      result 200, "The order #{@payload['order']['number']} was sent to OpenERP as #{response.name}."
    rescue => e
      result 500, e.message
    end
  end

  post '/update_order' do
    begin
      response = @client.send_updated_order(@payload, @config)
      result 200, "The order #{@payload['order']['number']} was sent to OpenERP as #{response.name}."
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

  post '/confirm_shipment' do
    begin
      code = 200
      response = @client.confirm_shipment
      add_messages 'shipment:confirm', response, :inflate => true
      set_summary 'All pending shipments from OpenERP have been marked as shipped.'
    rescue => e
      code = 500
      set_summary "An OpenERP Endpoint error has occured: #{e.message}"
    end
    process_result code
  end
end
