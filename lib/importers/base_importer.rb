require 'csv'
require 'csv_progress_bar'

class BaseImporter
  class << self
    attr_accessor :csv_path
    attr_accessor :klass
    attr_accessor :validate
  end

  attr_accessor :attributes, :row

  def initialize(row)
    @row = row
    @attributes = self.class.empty_attributes.dup
    build_attributes
  end

  def self.bulk_import(values)
    klass.import(columns, values, validate: false, timestamps: false)
  end

  def self.columns
    field_mapping.values
  end

  def self.empty_attributes
    @empty_attributes ||= columns.inject({}) { |memo, key|
      memo[key] = nil
      memo
    }
  end

  def self.field_mapping
    {}
  end

  def self.import
    values = []

    File.open(csv_path, "r:utf-8") do |file|
      csv = CSV.new(file, headers: true)
      csv.extend(CSVProgressBar) unless Rails.env.test?
      csv.each do |row|
        values << new(row).values

        if values.length % 1000 == 0
          bulk_import(values)
          values.clear
        end
      end

      bulk_import(values) unless values.empty?
    end

    after_import if respond_to?(:after_import, true)
  end

  def self.loan_id_from_legacy_id(legacy_id)
    @loan_id_from_legacy_id ||= begin
      {}.tap { |lookup|
        Loan.select('id, legacy_id').find_each do |loan|
          lookup[loan.legacy_id] = loan.id
        end
      }
    end

    @loan_id_from_legacy_id[legacy_id.to_i]
  end

  def values
    attributes.values
  end
end
