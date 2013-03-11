module PresenterFormatterConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def format(attribute, options)
      formatter = options.fetch(:with)

      attr_reader attribute

      define_method("#{attribute}=") do |value|
        instance_variable_set "@#{attribute}", formatter.parse(value)
      end
    end
  end
end
