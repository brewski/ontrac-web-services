#!/usr/bin/env ruby

require 'logger'
require 'ontrac'

include ::Ontrac::WebServices
include ::Ontrac::WebServices::Definitions

credentials = Service::Credentials.new(ENV.fetch("ONTRAC_ACCOUNT"), ENV.fetch("ONTRAC_PASSWORD"))
service = Service.new(credentials, StringIO.new(debug_output = ""))

requests = [ 10.1, 22, 15 ].map do |package_weight|
  ShipmentRequest.new.tap do |request|
    request.shipper = Shipper.new.tap do |shipper|
      shipper.Name    = "Fulfillment Circle"
      shipper.Addr1   = "343 Third Street\nSuite 17"
      shipper.City    = "sparks"
      shipper.State   = "NV"
      shipper.Zip     = "89434"
      shipper.Contact = "John D."
      shipper.Phone   = "(415) 350-2608"
    end
    request.consignee = Consignee.new.tap do |consignee|
      consignee.Name    = "Joe Shmoe"
      consignee.Addr1   = "123 4th St"
      consignee.Addr2   = "Suite 315"
      consignee.City    = "San Luis Obispo"
      consignee.State   = "CA"
      consignee.Zip     = "93401"
      consignee.Phone   = "(805) 555-1234"
    end
    request.Service = SERVICE_TYPE_GROUND
    request.SignatureRequired = false
    request.Residential = true
    request.SaturdayDel = false
    request.Declared = 0
    request.Weight = package_weight
    request.LabelType = LABEL_TYPE_PDF
    request.ShipDate = Time.new.strftime("%Y-%m-%d")
  end
end

logger = Logger.new($stderr)
begin
  service.post_shipments(requests).each do |(tracking_number, label, charge)|
    File.open("#{tracking_number}.pdf", "w") { |f| f << label }
    logger.info("label: ./#{tracking_number}.pdf, charge: #{charge}")
  end
rescue ServiceException => err
  logger.error("OnTrac Service Exception: #{err.message}")
  logger.error("Root Error: #{err.root_error}") if (err.root_error && !err.root_error.empty?)
  err.sub_errors.each do |uid, sub_error|
    logger.error("Sub Error (#{uid}): #{sub_error}")
  end
  raise
ensure
  if ($! && !debug_output.empty?)
    logger.debug("OnTrac HTTP debug output")
    debug_output.each_line.map(&:strip).each(&logger.method(:debug))
  end
end
