module Ontrac
  module WebServices
    module Definitions
      class ShipmentRequest < Base
        attr_accessor :account
        attr_accessor :password
        attr_accessor :request_reference
        attr_accessor :packages

        def self.basename
          "OntracShipmentRequest"
        end
      end
    end
  end
end