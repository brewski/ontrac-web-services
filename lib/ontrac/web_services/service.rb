require 'net/https'
require 'nokogiri'
require 'base64'

module Ontrac::WebServices
  class ServiceException < RuntimeError
    attr_accessor :details
  end

  class Service
    Credentials = Struct.new(:account, :password, :environment)

    def initialize(credentials)
      @credentials = credentials
    end

    def service_url(request_name)
      (@credentials.environment.to_sym == :production) ?
          "https://www.shipontrac.net/OnTracAPI/#{request_name}.ashx" :
          "https://www.shipontrac.net/OnTracAPItest/#{request_name}.ashx"
    end

    def request_shipment(service, shipper_data, delivery_data,
        label_type, package_weights, &process_contents)

      label_base64_encoded =
          label_type != Definitions::LABEL_TYPE_EPL_4X3 &&
          label_type != Definitions::LABEL_TYPE_EPL_4X5

      request = Definitions::ShipmentRequest.new
      request.account = @credentials.account
      request.password = @credentials.password

      request.packages = package_weights.map.with_index do |weight, ndx|
        Definitions::Package.new.tap do |package|
          package.package_data = Definitions::PackageData.new.tap do |data|
            data.shipper_data = shipper_data
            data.delivery_data = delivery_data

            data.package_detail = Definitions::PackageDetail.new.tap do |detail|
              detail.service = service
              detail.weight = weight
              detail.ship_email = ""
              detail.del_email = ""
              detail.label_type = label_type
            end
          end

          process_contents.call(package.package_data, ndx) if (process_contents)
        end
      end

      package_data_path = "/OnTracShipmentResponse/Package/PackageData"
      num_packages = package_weights.size

      request_xml = Nokogiri::XML::Document.new
      request_xml << request.to_xml

      issue_request("ShipmentRequest", request_xml) do |response_xml|
        %w(Label Tracking Charges/TotalCharge).each do |node_name|
          count = response_xml.xpath("count(#{package_data_path}/#{node_name})")
          if (response_xml.xpath("count(#{package_data_path}/#{node_name})") != num_packages)
            raise "Expected #{num_packages} #{node_name} response(s), received #{count}"
          end
        end

        response_xml.xpath("/OnTracShipmentResponse/Package/PackageData").map do |xml|
          label_img = xml.xpath("Label").text
          label_img = Base64.decode64(label_img) if (label_base64_encoded)

          [
            xml.xpath("Tracking").text,
            label_img,
            Float(xml.xpath("Charges/TotalCharge").text),
            xml
          ]
        end
      end
    end

    private
      def issue_request(request_type, request_xml, &process_response)
        uri = URI.parse(service_url(request_type))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        response = http.request_post(uri.request_uri, request_xml.to_s)
        response_xml = Nokogiri::XML(response.body)

        check_response(response_xml)
        process_response.call(response_xml)
      rescue Timeout::Error, SocketError => root_exception
        err = ServiceException.new("Network communication error")
        err.set_backtrace([ "#{__FILE__}:#{__LINE__ + 1}", *root_exception.backtrace ])
        raise err
      rescue Exception => root_exception
        err = ServiceException.new(root_exception.message)
        err.details = { request: request_xml.to_s, response: response.body }
        err.set_backtrace([ "#{__FILE__}:#{__LINE__ + 1}", *root_exception.backtrace ])
        raise err
      end

      def check_response(response_xml)
        status = response_xml.xpath("/OnTracShipmentResponse/Status").text
        message = response_xml.xpath("/OnTracShipmentResponse/Message").text
        package_messages = response_xml.xpath("//PackageData/Message")

        if (status.empty? || status != "1" || response_xml.xpath("//PackageData/Status != 1"))
          msg = "No status information was returned for the request"    if (status.empty?)
          msg = message || "The request returned a status of #{status}" if (status != "1")
          msg << " -- " + [ *package_messages.to_a ] * " ; " if (!package_messages.empty?)

          raise msg
        end
      end
  end
end