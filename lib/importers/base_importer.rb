require 'csv'

class BaseImporter
  class << self
    attr_accessor :csv_path
    attr_accessor :klass
  end

  def initialize(row)
    @row = row
  end

  def self.import
    csv = CSV.read(csv_path, headers: true)
    csv.each do |row|
      attributes = new(row).attributes
      model = klass.new

      attributes.each do |key, value|
        model[key] = value
      end

      model.save(validate: false)
    end
    # call after_import hook
  end

end
