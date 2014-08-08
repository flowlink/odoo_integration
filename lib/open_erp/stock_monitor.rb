module OpenErp
  class StockMonitor
    class << self
      def run!(payload)
        unless product = ProductProduct.first(fields: ['default_code', '=', payload[:inventory][:sku]])
          raise OpenErpEndpointError, "Could not find inventory for #{payload[:inventory][:id]}"
        end

        {
          sku: payload[:inventory][:sku],
          quantity: product.qty_available.to_i
        }
      end
    end
  end
end
