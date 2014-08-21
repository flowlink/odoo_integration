require 'spec_helper'

ProductProduct = OpenStruct.new

describe OpenErp::ProductImporter do
  let(:product) do
    OpenStruct.new name: "A product",
      description: "I have no variants",
      price: 20.99,
      default_code: "FOOBAR"
  end
  let(:variant_product) do
    OpenStruct.new name: "A product",
      description: "I have a variant",
      permalink: "i-am-a-variant",
      price: 20.99,
      default_code: "FOOBAR1",
      variants: "A Variant"
  end

  describe '.run!' do
    context 'when there are products to import' do
      it 'returns an array of product:import messages' do
        ProductProduct.should_receive(:find).exactly(:once).and_return([product, variant_product])
        result = described_class.run!
        result.should be_a Array
        result.length.should == 2
        result.first[:name].should == product.name
        result.last[:variants].first[:name].should == variant_product.variants
      end

      context 'when a variant is found' do
        before(:each) { ProductProduct.should_receive(:find).exactly(:once).and_return([variant_product]) }

        it 'returns a product:import message with an embedded variant' do
          result = described_class.run!
          result.should be_a Array
          result.length.should == 1
          result.first[:variants].first[:name].should == variant_product.variants
        end

        it 'uses the permalink as the master product sku' do
          result = described_class.run!
          result.first[:name].should == variant_product.name
        end

        it "returns proper options for the variant" do
          result = described_class.run!
          result.first[:variants].first[:options].first[0].should == "a-variant"
          result.first[:variants].first[:options].first[1].should == variant_product.variants
        end
      end
    end

    context 'when there are no products to import' do
      it 'returns an empty array' do
        ProductProduct.should_receive(:find).exactly(:once).and_return([])
        result = described_class.run!
        result.should be_a Array
        result.should be_empty
      end
    end
  end
end
