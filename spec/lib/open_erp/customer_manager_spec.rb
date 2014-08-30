require 'spec_helper'

describe OpenErp::CustomerManager do
  before(:all) do
    VCR.use_cassette('ooor') do
      Ooor.new url: ENV['OERP_URL'],
               database: ENV['OERP_DB'],
               username: ENV['OERP_USER'],
               password: ENV['OERP_PASS']
    end
  end

  before(:each) do
    @payload ={
      'order' => Factories.order,
      'original' => Factories.original,
      'parameters' => Factories.parameters
    }
  end

  subject do
    VCR.use_cassette('customer_manager') do
      OpenErp::CustomerManager.new(ResPartner.find(email: 'jdyer@spreecommerce.com').first, @payload)
    end
  end

  pending '#update!' do
    context 'updating an existing customer' do
      it 'updates the billing address' do
        @payload['order']['billing_address']['address1'] = '123 Foo Street'

        VCR.use_cassette('update_existing_customer') do
          customer = subject.update!
          customer.street.should == '123 Foo Street'
        end
      end

      it 'creates a shipping customer if the shipping address is different than the billing address' do
        VCR.use_cassette('update_existing_create_shipping_customer') do
          subject.update!
          shipping_customer = ResPartner.find(name: 'Brian Quinn', type: 'delivery').first
          shipping_customer.street.should == '7735 Old Georgetown Rd'
        end
      end
    end

    context 'updating a new customer' do
      subject { OpenErp::CustomerManager.new(ResPartner.new, @payload) }

      it 'creates a billing customer' do
        subject.customer.id.should_not be_present

        VCR.use_cassette('update_new_customer') do
          customer = subject.update!
          customer.id.should be_present
          customer.type.should == 'default'
        end
      end
    end
  end
end
