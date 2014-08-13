require 'spec_helper'

describe OpenErpEndpoint do
  let(:order) { Factory.order_payload }
  let(:params) { Factory.config }

  describe 'orders > sale order' do
    it 'sends the order to OpenERP' do
      order[:id] = "R45432522354"
      order[:placed_on] = "2014-08-13T00:29:15.219Z"

      message = {
        order: order,
        parameters: params
      }.to_json

      VCR.use_cassette('orders/add_order') do
        post '/add_order', message, auth
        last_response.status.should == 200
        last_response.body.should match /was sent to OpenERP/
      end
    end

    context 'updated order' do
      it 'sends the order to OpenERP' do
        order[:id] = "R45432522354"
        order[:placed_on] = "2014-08-13T00:29:15.219Z"

        message = {
          order: order,
          parameters: params
        }.to_json

        VCR.use_cassette('orders/update_order') do
          post '/update_order', message, auth
          last_response.status.should == 200
          last_response.body.should match /was sent to OpenERP/
        end
      end
    end
  end

  describe '/get_inventory' do
    context 'success' do
      it 'gives back inventory stock for given object' do
        message = {
          inventory: {
            id: '123',
            sku: 'ROR-00011'
          },
          parameters: params
        }.to_json

        VCR.use_cassette('inventory/get') do
          post '/get_inventory', message, auth
          last_response.status.should == 200
          expect(json_response[:inventories].count).to eq 1
        end
      end
    end

    context 'failure' do
      it 'returns an error notification if the product does not exist on OpenERP' do
        message = {
          inventory: {
            sku: "not there never there not there"
          },
          parameters: params
        }.to_json

        VCR.use_cassette('inventory/product_not_found') do
          post '/get_inventory', message, auth
          last_response.status.should == 500
          expect(json_response[:summary]).to match "Could not find inventory for"
        end
      end
    end
  end

  pending '/get_shipments' do
    context 'success' do
      it 'generates a shipment confirm message for a shipped order' do
        message = {
          parameters: params
        }.to_json

        VCR.use_cassette('confirm_shipment_success') do
          post '/confirm_shipment', message, auth
          last_response.status.should == 200
          last_response.body.should match /Confirmed shipment/
          last_response.body.should match /shipment:confirm/
          last_response.body.should match /inflate/
        end
      end
    end
  end

  describe '/get_products' do
    it 'returns product objects' do
      VCR.use_cassette('products/get') do
        post '/get_products', { parameters: params }.to_json, auth
        last_response.status.should == 200
        binding.pry
        expect(json_response[:products].count).to be > 1
      end
    end
  end
end
