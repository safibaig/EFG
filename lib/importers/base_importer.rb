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
    index = 0
    CSV.foreach(csv_path, headers: true) do |row|
      attributes = new(row, index).attributes
      model = klass.new

      attributes.each do |key, value|
        setter_method = "#{key}="
        model.respond_to?(setter_method) ? model.send(setter_method, value) : model[key] = value
      end

      model.save!
      index += 1
    end
    after_import
  end

  def self.after_import
  end

end
