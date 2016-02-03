# ontrac-web-services
## Description
This gem provides an interface to the OnTrac web services API.  It interfaces with its HTTP/POST API to generate labels.

## Examples
### Creating a shipment with multiple packages

```ruby
require 'ontrac'

include ::Ontrac::WebServices
include ::Ontrac::WebServices::Definitions

credentials = Service::Credentials.new("37", "testpass", "test")
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

begin
  service.post_shipments(requests).each do |(tracking_number, label, charge)|
    puts "tracking number: #{tracking_number}"
    File.open("#{tracking_number}.pdf", "w") { |f| f << label }
    puts "charge: #{charge}"
  end
rescue ServiceException => err
  $stderr.puts err.message, ""
  $stderr.puts "Debug Output:", debug_output, ""
  $stderr.puts "Root Error:", err.root_error, ""
  $stderr.puts "Sub Errors:", err.sub_errors, ""
  $stderr.puts "Backtrace:", $!.backtrace
end
```
