module OpenErp
  class CustomerManager
    attr_reader :customer, :payload

    def initialize(customer, payload)
      @customer = customer
      @payload  = payload
    end

    def update!
      update_category
      update_addresses

      # Without the following, @customer.signup_valid will be nil
      # which causes problems
      @customer.signup_token = true

      @customer.save
      @customer
    end

    private

    def update_category
      @customer.category_id = []
    end

    def update_addresses
      if payload['order']['shipping_address'] == payload['order']['billing_address']
        update_billing_address
      else
        update_billing_address
        create_shipping_customer
      end
    end

    def update_billing_address
      address = payload['order']['billing_address']
      #customer.type       = "default"
      @customer.email      = payload['order']['email']
      @customer.name       = "#{address['firstname']} #{address['lastname']}"
      @customer.street     = address['address1']
      @customer.street2    = address['address2']
      @customer.city       = address['city']
      @customer.zip        = address['zipcode']
      @customer.phone      = address['phone']
      @customer.country_id = ResCountry.find(code: address['country']).first.id

      if address['state'].present?
        # search via code vs name
        if address['state'].length > 2
          @customer.state_id = (!ResCountryState.find(name: address['state']).blank?) ? ResCountryState.find(name: address['state']).first.id : nil
        else
          @customer.state_id = (!ResCountryState.find(code: address['state']).blank?)  ? ResCountryState.find(code: address['state']).first.id : nil
        end
      end
    end

    def create_shipping_customer
      ship_customer = ResPartner.new
      address = payload['order']['shipping_address']
      ship_customer.name       = "#{address['firstname']} #{address['lastname']}"
      ship_customer.type       = "delivery"
      ship_customer.email      = payload['order']['email']
      ship_customer.street     = address['address1']
      ship_customer.street2    = address['address2']
      ship_customer.city       = address['city']
      ship_customer.zip        = address['zipcode']
      ship_customer.phone      = address['phone']
      ship_customer.country_id = ResCountry.find(code: address['country']).first.id

      # Without the following, @customer.signup_valid will be nil
      # which causes problems
      ship_customer.signup_token = true

      if address['state'].present?
        # search via code vs name
        if address['state'].length > 2
          ship_customer.state_id = (!ResCountryState.find(name: address['state']).blank?) ? ResCountryState.find(name: address['state']).first.id : nil
        else
          ship_customer.state_id = (!ResCountryState.find(code: address['state']).blank?)  ? ResCountryState.find(code: address['state']).first.id : nil
        end
      end

      ship_customer.category_id = []

      ship_customer.save
    end
  end
end
