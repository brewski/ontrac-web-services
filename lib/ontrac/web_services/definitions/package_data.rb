module Ontrac
  module WebServices
    module Definitions
      class PackageData < Base
        attr_accessor :uid
        attr_accessor :shipper_data
        attr_accessor :delivery_data
        attr_accessor :package_detail

        def uid_to_xml_name
          "UID"
        end
      end
    end
  end
end
