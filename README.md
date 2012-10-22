# ontrac-web-services
## Description
This gem provides an interface to the OnTrac web services API.  It interfaces with its HTTP/POST API to generate labels (looking up shipping rates and tracking coming soon).

## Examples
### Creating a shipment with multiple packages

```ruby
  require 'ontrac'

  include ::Ontrac::WebServices
  include ::Ontrac::WebServices::Definitions

  credentials = Service::Credentials.new("ACCOUNT #", "PASSWORD", "production")
  service = Service.new(credentials)

  shipper = ShipperData.new
  shipper.name    = "Fulfillment Circle"
  shipper.address = "343 third street"
  shipper.suite   = "suite 17"
  shipper.city    = "sparks"
  shipper.state   = "nv"
  shipper.zip     = "89434"
  shipper.phone   = "(415) 350-2608"

  recipient = DeliveryData.new
  recipient.name     = "Joe Shmoe"
  recipient.address  = "123 4th St"
  recipient.address2 = "Suite 315"
  recipient.city     = "San Luis Obispo"
  recipient.state    = "CA"
  recipient.zip      = "93401"
  recipient.phone    = "(805) 555-1234"

  responses = service.request_shipment(SERVICE_TYPE_GROUND, shipper, recipient, LABEL_TYPE_PDF,
      [ 22.0, 15, 10 ]) do |package_data, package_num|

    package_data.package_detail.residential = false
    package_data.package_detail.reference = "order #1234"
  end

  tracking_numbers = responses.map do |(tracking_number, label, charge)|
    puts "tracking number: #{tracking_number}"
    puts "charge: #{charge.to_f}"
    File.open("#{tracking_number}.pdf", "w") { |f| f << label }
    tracking_number
  end
```