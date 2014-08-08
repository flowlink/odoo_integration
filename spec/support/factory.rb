module Factory
  class << self
    Dir.entries("#{File.dirname(__FILE__)}/samples").each do |file_name|
      next if file_name == '.' or file_name == '..'
      name, ext = file_name.split(".", 2)

      define_method("#{name}_payload") do
        JSON.parse(IO.read("#{File.dirname(__FILE__)}/samples/#{name}.json")).with_indifferent_access
      end
    end

    def config
      {
        'openerp_api_user'                   => ENV['OPENERP_USER'],
        'openerp_api_password'               => ENV['OPENERP_PASS'],
        'openerp_api_database'               => ENV['OPENERP_DB'],
        'openerp_api_url'                    => ENV['OPENERP_URL'],
        'openerp_shop'                       => '1',
        'openerp_shipping_policy'            => 'Deliver all products at once',
        'openerp_shipping_name'              => 'FREE CARRIER',
        'openerp_invoice_policy'             => 'Before Delivery',
        'openerp_pricelist'                  => 'Public Pricelist',
        'openerp_shipping_lookup'            => []
      }
    end
  end
end
