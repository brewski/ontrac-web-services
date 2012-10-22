module Ontrac::WebServices
  module Definitions
    SERVICE_TYPE_SUNRISE = 'S'
    SERVICE_TYPE_GOLD    = 'G'
    SERVICE_TYPE_GROUND  = 'C'
    SERVICE_TYPE_FREIGHT = 'H'

    LABEL_TYPE_PDF     = 1
    LABEL_TYPE_JPG     = 2
    LABEL_TYPE_BMP     = 3
    LABEL_TYPE_GIF     = 4
    LABEL_TYPE_EPL_4X3 = 5
    LABEL_TYPE_EPL_4X5 = 6
    LABEL_TYPE_ZPL_4X5 = 7
  end
end

require 'ontrac/web_services/definitions/base'
require 'ontrac/web_services/definitions/delivery_data'
require 'ontrac/web_services/definitions/package'
require 'ontrac/web_services/definitions/package_data'
require 'ontrac/web_services/definitions/package_detail'
require 'ontrac/web_services/definitions/shipment_request'
require 'ontrac/web_services/definitions/shipper_data'
