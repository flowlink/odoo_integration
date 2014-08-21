module OpenErp
  class ShippingMonitor
    class << self
      def run!
        orders = SaleOrder.find(:all, :domain => ['x_poll_for_shipping', '=', true])
        result = []

        orders.each do |order|
          order.x_poll_for_shipping = false
          order.save

          result << ShippingMonitor.shipments_to_shipment_confirm_messages(order)
        end
        result.flatten
      end

      def find_order_shipments(order)
        order.order_line.find { |ol| ol.name =~ /Shipping/ }.name
          .split('- ').last.split(',').map(&:strip)
      rescue
        raise OpenErpEndpointError, "No shipment line item could be found for order #{order.name}!"
      end

      def shipments_to_shipment_confirm_messages(order)
        ShippingMonitor.find_order_shipments(order).map do |shipment_number|
          {
            id: shipment_number,
            order_id: order.name,
            tracking: order.x_tracking_number
          }
        end
      end
    end
  end
end
