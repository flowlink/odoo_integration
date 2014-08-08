require 'spec_helper'

describe OpenErp::StockMonitor do
  before(:all) do
    VCR.use_cassette('ooor') do
      Ooor.new url:      ENV['OPENERP_URL'],
               database: ENV['OPENERP_DB'],
               username: ENV['OPENERP_USER'],
               password: ENV['OPENERP_PASS']
    end
  end

  let(:config) { Factory.config }
  let(:product) { Factory.product_payload }

  let(:payload) do
    {
      inventory: {
        sku: product[:sku],
        parameters: config
      }
    }.with_indifferent_access
  end

  describe '.run!' do
    context 'when the products exists' do
      it 'returns product sku and quantity as a hash' do
        VCR.use_cassette('monitor_stock_success') do
          result = OpenErp::StockMonitor.run! payload
          result.should be_a Hash

          result[:sku].should == product[:sku]
          # result[:quantity].should == 50
        end
      end
    end

    context 'when the product does not exist' do
      it 'raises an error' do
        @payload['sku'] = 'NOTASKU'
        VCR.use_cassette('monitor_stock_failure') do
          expect { OpenErp::StockMonitor.run!(@payload) }.to raise_error(OpenErpEndpointError)
        end
      end
    end
  end
end
