require 'csv'
require 'sequel'

class BaseImporter
  class << self
    attr_accessor :csv_path
    attr_accessor :table_name
  end

  DB = Sequel.connect(YAML.load_file(Rails.root.join('config/database.yml'))[Rails.env])

  attr_accessor :attributes, :row

  def initialize(row)
    @row = row
    parse_row
  end

  def self.bulk_import(values)
    DB[table_name].import(columns, values)
    values.clear
  end

  def self.columns
    field_mapping.values
  end

  def self.field_mapping
    {}
  end

  def self.import
    CSV.foreach(csv_path, headers: true) do |row|
      values << new(row).values
      bulk_import(values) if values.length % 1000 == 0
    end

    bulk_import(values)
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
