module OpenErp
  class StockMonitor
    class << self
      def run!(payload)
        reference = payload[:inventory][:id]

        unless product = ProductProduct.find(reference)
          raise OpenErpEndpointError, "Could not find inventory for Product ID #{reference}"
        end

        {
          id: payload[:inventory][:id],
          quantity: product.qty_available.to_i
        }
      end
    end
  end
end
