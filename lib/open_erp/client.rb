module OpenErp
  class Client
    attr_reader :client

    def initialize(params)
      @client = Ooor.new(params)
    rescue
      raise OpenErpEndpointError, 'There was a problem establishing a connection to OpenERP.
        Please ensure your credentials are valid.'
    end


    def send_order(payload, config)
      OpenErp::OrderBuilder.new(payload, config).build!
    end

    def send_updated_order(payload, config)
      OpenErp::OrderBuilder.new(payload, config).update!
    end

    def update_stock(payload)
      OpenErp::StockMonitor.run!(payload)
    end

    def confirm_shipment
      OpenErp::ShippingMonitor.run!
    end

    def import_products
      OpenErp::ProductImporter.run!
    end
  end
end
