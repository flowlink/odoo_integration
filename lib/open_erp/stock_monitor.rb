module OpenErp
  class StockMonitor
    class << self
      def run!(payload)
        unless product = ProductProduct.find(:all, domain: ['default_code', '=', payload[:inventory][:sku]]).first
          raise OpenErpEndpointError, "Could not find inventory for #{payload[:inventory][:sku]}"
        end

        {
          id: payload[:inventory][:id],
          sku: payload[:inventory][:sku],
          quantity: product.qty_available.to_i
        }
      end
    end
  end
end
