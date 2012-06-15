require 'csv'
require 'sequel'

class BaseImporter
  class << self
    attr_accessor :csv_path
    attr_accessor :klass
  end

  attr_accessor :attributes, :row

  def initialize(row)
    @row = row
    parse_row
  end

  def self.bulk_import(values)
    klass.import(columns, values, validate: false, timestamps: false)
    values.clear
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
      bulk_import(values) if values.length % 1000 == 0
    end

    bulk_import(values) unless values.empty?
  end

  def parse_row
    self.attributes = row.inject({}) { |memo, (name, value)|
      memo[self.class.field_mapping[name]] = value
      memo
    }
  end

  def values
    attributes.values
  end
end
