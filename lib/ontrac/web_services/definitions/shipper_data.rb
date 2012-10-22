module Ontrac
  module WebServices
    module Definitions
      class ShipperData < Base
        attr_accessor :name
        attr_accessor :address
        attr_accessor :suite
        attr_accessor :city
        attr_accessor :state
        attr_accessor :zip
        attr_accessor :phone
        attr_accessor :contact
      end
    end
  end
end