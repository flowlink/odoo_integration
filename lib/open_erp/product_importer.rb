module OpenErp
  class ProductImporter
    class << self
      def run!
        products = ProductProduct.find(:all, :domain => ['waiting_spree_import', '=', true])
        result = []

        non_variant_products = products.find_all { |p| p.variants.nil? }.first(25)
        variant_products = products.find_all { |p| !p.variants.nil? }.first(25)

        non_variant_products.each do |product|
          begin
            result << ProductImporter.product_to_product_import_message(product)
          rescue StandardError => e
            raise OpenErpEndpointError, "The product #{product.name} could not be imported!"
          end
          product.waiting_spree_import = false
          product.save
        end

        variant_products.each do |product|
          begin
            result << ProductImporter.variant_product_to_product_import_message(product)
          rescue StandardError => e
            raise OpenErpEndpointError, "The product #{product.name} could not be imported!"
          end
          product.waiting_spree_import = false
          product.save
        end

        result
      end

      def product_to_product_import_message(product)
        {
          id: product.id,
          sku: product.default_code,
          name: product.name,
          price: product.list_price,
          description: product.description
        }
      end

      def variant_product_to_product_import_message(product)
        {
          id: product.id,
          sku: product.permalink,
          name: product.name,
          price: product.list_price,
          description: product.description,
          variants: [
            {
              name: product.variants,
              sku: product.default_code,
              price: product.list_price,
              options: {
                ProductImporter.hyphenate_variant(product.variants) => product.variants
              }
            }
          ]
        }
      end

      def hyphenate_variant(name)
        name.downcase.gsub(' ', '-')
      end
    end
  end
end
