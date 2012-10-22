module Ontrac
  module WebServices
    module Definitions
      class DeliveryData < Base
        attr_accessor :name
        attr_accessor :address
        attr_accessor :address2
        attr_accessor :address3
        attr_accessor :city
        attr_accessor :state
        attr_accessor :zip
        attr_accessor :phone
        attr_accessor :contact
      end
    end
  end
end

# [ DeliveryData, Package, PackageData, PackageDetail, ShipmentRequest, ShipperData ].map do |cls|
#   accessors = cls.attributes.map { |a| "        attr_accessor :#{a.to_s.underscore}" }
# <<-CLSDEF
# module Ontrac
#   module WebServices
#     module Definitions
#       class #{cls.name.split("::").last} < Base
# #{accessors * "\n"}
#       end
#     end
#   end
# end
# CLSDEF
# end