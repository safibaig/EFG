require 'csv'

class BaseImporter
  class << self
    attr_accessor :csv_path
    attr_accessor :klass
  end

  def initialize(row, row_number)
    @row = row
    @row_number = row_number
  end

  def self.import
    csv = CSV.read(csv_path, headers: true)
    csv.each_with_index do |row, index|
      attributes = new(row, index).attributes
      model = klass.new

      attributes.each do |key, value|
        setter_method = "#{key}="
        model.respond_to?(setter_method) ? model.send(setter_method, value) : model[key] = value
      end
      model.save!
    end
    after_import
  end

  def self.after_import
    raise NotImplementedError
  end

end
