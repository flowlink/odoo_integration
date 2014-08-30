require 'spec_helper'

describe OpenErp::OrderBuilder do
  before do
    VCR.use_cassette('ooor') do
      Ooor.new url: ENV['OPENERP_URL'],
               database: ENV['OPENERP_DB'],
               username: ENV['OPENERP_USER'],
               password: ENV['OPENERP_PASS']
    end
  end

  let(:payload) { { order: Factory.order_payload } }
  let(:config) { Factory.config }

  subject do
    OpenErp::OrderBuilder.new(payload, Factory.config)
  end

  describe "#build!" do
    it "sets the required attributes" do
      payload[:order][:id] = "R45345899878976"

      VCR.use_cassette('build_order') do
        order = subject.build!
        expect(order).to be_persisted

        order.partner_id.should be_present
        order.partner_shipping_id.should be_present
        order.shop_id.should be_present
        order.pricelist_id.should be_present
        order.picking_policy.should be_present
        order.order_policy.should be_present
        order.invoice_quantity.should == 'order'
        order.order_line.should be_present
        order.currency_id.should be_present
        order.incoterm.should be_present
      end
    end
  end

  describe "#update!" do
    it "updates line items" do
      payload[:order][:line_items].each { |li| li[:quantity] = 10.0 }

      VCR.use_cassette('order_update') do
        order = subject.update!
        order.order_line.first.product_uom_qty.should == 10.0
      end
    end
  end
end
