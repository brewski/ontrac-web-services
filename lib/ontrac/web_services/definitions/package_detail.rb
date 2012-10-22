module Ontrac
  module WebServices
    module Definitions
      class PackageDetail < Base
        attr_accessor :ship_date
        attr_accessor :reference
        attr_accessor :tracking
        attr_accessor :service
        attr_accessor :declared
        attr_accessor :cod
        attr_accessor :cod_type
        attr_accessor :saturday_delivery
        attr_accessor :signature_rqd
        attr_accessor :type
        attr_accessor :weight
        attr_accessor :bill_to
        attr_accessor :instructions
        attr_accessor :ship_email
        attr_accessor :del_email
        attr_accessor :label_type
        attr_accessor :residential

        def cod_type_to_xml_name
          "cod_Type"
        end
      end
    end
  end
end
