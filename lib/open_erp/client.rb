module OpenErp
  class Client
    require 'ooor'

    attr_reader :client

    def initialize(params)
      tries ||= 3
      @client = Ooor.new(params)
    rescue
      if (tries -= 1) > 0
        sleep 2
        retry
      else
        raise OpenErpEndpointError,
             "There was a problem establishing a connection to OpenERP." +
             "Please ensure your credentials are valid."
      end
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
