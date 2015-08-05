require 'net/https'
require 'nokogiri'
require 'base64'
require 'cgi'
require 'securerandom'

module Ontrac::WebServices
  class ServiceException < Exception
  end

  class Service
    Credentials = Struct.new(:account, :password, :environment)

    attr_accessor :debug_output

    def initialize(credentials, debug_output = nil)
      @credentials = credentials
      self.debug_output = debug_output
    end

    def service_url(service_name)
      url_base = (@credentials.environment.to_sym == :production) ?
          "https://www.shipontrac.net/OnTracWebServices/OnTracServices.svc/V2" :
          "https://www.shipontrac.net/OnTracTestWebServices/OnTracServices.svc/V2"

      "%s/%s/%s?pw=%s" % [
        url_base, @credentials.account, service_name, CGI.escape(@credentials.password)
      ]
    end

    def post_shipments(shipment_requests)
      shipment_requests.map do |shipment_request|
        shipment_request.shipper.Contact ||= ""
        shipment_request.shipper.Phone ||= ""

        shipment_request.consignee.Addr2 ||= ""
        shipment_request.consignee.Addr3 ||= ""
        shipment_request.consignee.Contact ||= ""
        shipment_request.consignee.Phone ||= ""

        shipment_request.UID = SecureRandom.hex(16)
        shipment_request.COD ||= 0
        shipment_request.CODType ||= COD_TYPE_NONE
        shipment_request.BillTo ||= 0
        shipment_request.Instructions ||= ""
        shipment_request.Reference ||= ""
        shipment_request.Reference2 ||= ""
        shipment_request.Reference3 ||= ""
        shipment_request.Tracking ||= ""
        shipment_request.DIM ||= Dim.new(0, 0, 0)
        shipment_request.ShipEmail ||= ""
        shipment_request.DelEmail ||= ""
      end

      xml_builder = Nokogiri::XML::Builder.new
      xml_builder.OnTracShipmentRequest do |xml|
        xml.Shipments do |xml|
          shipment_requests.each do |shipment_request|
            xml.parent << shipment_request.to_xml("Shipment")
          end
        end
      end

      response_xml = issue_request('shipments', xml_builder.doc)
      shipment_requests.map do |request|
        uid = request.UID
        shipment_response = response_xml.xpath(
          "/OnTracShipmentResponse/Shipments/Shipment[./UID = '#{uid}']"
        ).first or raise ServiceException.new("Missing package response for #{uid}")

        label = shipment_response.xpath("Label").text
        label = Base64.decode64(label) if (request.LabelType == Definitions::LABEL_TYPE_PDF)
        [
          shipment_response.xpath("Tracking").text,
          label,
          Float(shipment_response.xpath("TotalChrg").text)
        ]
      end
    end

    private
      def issue_request(service_name, request_xml)
        uri = URI.parse(service_url(service_name))
        http = Net::HTTP.new(uri.host, uri.port)
        http.set_debug_output(debug_output) if (debug_output)
        http.use_ssl = true

        response = http.request_post(uri.request_uri, request_xml.to_s)
        response_xml = Nokogiri::XML(response.body)

        check_response(response_xml)
        response_xml
      end

      def check_response(response_xml)
        root_error = response_xml.xpath("/OnTracShipmentResponse/Error").text
        shipment_errors = response_xml.xpath("//Shipment/Error")

        return if (root_error.empty? && shipment_errors.all? { |err| err.text.empty? })

        raise ServiceException.new("OnTrac shipping error: #{root_error}")
      end
  end
end