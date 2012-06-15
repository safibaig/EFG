require 'csv'

class BaseImporter
  class << self
    attr_accessor :csv_path
    attr_accessor :klass
    attr_accessor :validate
  end

  attr_accessor :attributes, :row

  def initialize(row)
    @row = row
  end

  def self.bulk_import(values)
    klass.import(columns, values, validate: false, timestamps: false)
  end

  def self.columns
    field_mapping.values
  end

  def self.field_mapping
    {}
  end

  def self.import
    values = []

    CSV.foreach(csv_path, headers: true) do |row|
      values << new(row).values

      before_save(model)

      if values.length % 1000 == 0
        bulk_import(values)
        values.clear
      end
    end

    bulk_import(values) unless values.empty?

    after_import if respond_to?(:after_import, true)
  end

  def attributes
    row.inject({}) { |memo, (name, value)|
      memo[self.class.field_mapping[name]] = value
      memo
    }
  end

  def values
    attributes.values
  end
end
