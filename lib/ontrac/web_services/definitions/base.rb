require 'active_support'
require 'nokogiri'

module Ontrac::WebServices::Definitions
  class Base
    include Nokogiri

    def self.attr_accessor(*args)
      (@attributes ||= []).concat(args)
      super
    end

    def self.attributes
      return (@attributes ||= [])
    end

    def self.basename
      ActiveSupport::Inflector.camelize(self.name.gsub(/^.*::/, ''))
    end

    def to_xml
      xml_builder = Nokogiri::XML::Builder.new

      xml_builder.send(self.class.basename) do |xml|
        self.class.attributes.each do |attribute_name|
          (values = *self.send(attribute_name)).each do |attribute_value|
            xml_attr_name = respond_to?("#{attribute_name}_to_xml_name") ?
                send("#{attribute_name}_to_xml_name") :
                ActiveSupport::Inflector.camelize(attribute_name, false)

            if (attribute_value.is_a?(Base))
              xml.doc.root << attribute_value.to_xml
            else
              xml.send(xml_attr_name, attribute_value)
            end
          end
        end
      end

      xml_builder.doc.root
    end
  end
end