module FormatterConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def format(attribute, options)
      formatter = options[:with]

      define_method(attribute) do
        value = read_attribute(attribute)
        formatter.format(value)
      end

      define_method("#{attribute}=") do |value|
        parsed = formatter.parse(value)
        write_attribute(attribute, parsed)
      end
    end
  end
end
