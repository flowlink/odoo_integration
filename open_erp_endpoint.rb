require_relative './lib/open_erp'

class OpenErpEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  before do
    @client = OpenErp::Client.new(@config['openerp_api_url'], @config['openerp_api_database'],
                                  @config['openerp_api_user'], @config['openerp_api_password'])
  end

  post '/get_products' do
    begin
      code = 200

      @client.import_products.each do |product|
        add_object 'product', product
      end

      set_summary 'All products waiting for import from OpenERP have been imported.'
    rescue => e
      code = 500
      set_summary e.message
    end
    process_result code
  end

  post '/add_order' do
    begin
      code = 200
      response = @client.send_order(@payload, @config)
      set_summary "The order #{@payload['order']['number']} was sent to OpenERP as #{response.name}."
    rescue => e
      code = 500
      set_summary e.message
    end

    process_result code
  end

  post '/update_order' do
    begin
      code = 200
      response = @client.send_updated_order(@payload, @config)
      set_summary "The order #{@payload['order']['number']} was sent to OpenERP as #{response.name}."
    rescue => e
      code = 500
      set_summary e.message
    end

    process_result code
  end

  post '/get_inventory' do
    begin
      code = 200
      response = @client.update_stock(@payload)
      add_message 'stock:actual', response

      set_summary "Stock updated for product #{@payload['sku']}. This products count on hand now reflects the inventory_qty from OpenERP."
    rescue => e
      code = 500
      error_notification(e)
    end
    process_result code
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
