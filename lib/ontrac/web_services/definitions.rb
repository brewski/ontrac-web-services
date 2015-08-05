module Ontrac
  module WebServices
    module Definitions
      class DefinitionBase < Struct
        def initialize(*)
          super
        end

        def to_xml(root_name = nil)
          xml_builder = Nokogiri::XML::Builder.new
          root_name ||= self.class.name.split("::").last

          xml_builder.send(root_name) do |xml|
            members.each do |field|
              value = send(field)
              if (DefinitionBase === value)
                xml.doc.root << value.to_xml(field)
              else
                xml.send(field, value) unless (value.nil?)
              end
            end
          end

          xml_builder.doc.root
        end
      end

      Shipper = DefinitionBase.new(
        :Name,
        :Addr1,
        :City,
        :State,
        :Zip,
        :Contact,
        :Phone
      )
      Consignee = DefinitionBase.new(
        :Name,
        :Addr1,
        :Addr2,
        :Addr3,
        :City,
        :State,
        :Zip,
        :Contact,
        :Phone
      )
      Dim = DefinitionBase.new(
        :Length,
        :Width,
        :Height
      )
      ShipmentRequest = DefinitionBase.new(
        :UID,
        :shipper,
        :consignee,
        :Service,
        :SignatureRequired,
        :Residential,
        :SaturdayDel,
        :Declared,
        :COD,
        :CODType,
        :Weight,
        :Letter,
        :BillTo,
        :Instructions,
        :Reference,
        :Reference2,
        :Reference3,
        :Tracking,
        :DIM,
        :LabelType,
        :ShipEmail,
        :DelEmail,
        :ShipDate,
        :CargoType
      )

      SERVICE_TYPE_GROUND = "C"
      SERVICE_TYPE_SUNRISE = "S"
      SERVICE_TYPE_SUNRISE_GOLD = "G"
      SERVICE_TYPE_PALLETIZED_FREIGHT = "H"

      LABEL_TYPE_NONE = 0
      LABEL_TYPE_PDF = 1
      LABEL_TYPE_EPL_4_X_5 = 6
      LABEL_TYPE_ZPL_4_X_5 = 7

      COD_TYPE_NONE = "NONE"
      COD_TYPE_UNSECURED = "UNSECURED "
      COD_TYPE_SECURED = "SECURED"
    end
  end
end
