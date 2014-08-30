require 'spec_helper'

SaleOrder = OpenStruct.new

describe OpenErp::ShippingMonitor do
  let(:order) do
    OpenStruct.new name: "R12345",
      x_tracking_number: "123",
      order_line: [OpenStruct.new(name: "Shipping - H123, H234")]
  end

  pending ".run!" do
    it "returns shipments to process" do
      SaleOrder.should_receive(:find).exactly(:once).and_return([order])
      result = described_class.run!
      result.should be_a Array
      result.length.should == 2
    end

    it "return an empty array if no orders could be found" do
      SaleOrder.should_receive(:find).exactly(:once).and_return([])
      result = described_class.run!
      result.should be_a Array
      result.should be_empty
    end
  end

  pending ".find_order_shipments" do
    it "returns the shipment numbers from the order" do
      described_class.find_order_shipments(order).should == ["H123", "H234"]
    end
  end

  pending ".shipments_to_shipment_confirm_messages" do
    it "returns an array of shipment:confirm messages" do
      messages = described_class.shipments_to_shipment_confirm_messages(order)
      messages.length.should == 2
      messages.all? { |m| m[:shipment][:number].present? }.should be_true
    end
  end
end
