require 'csv'

class BaseCsvExport

  include Enumerable

  def initialize(records)
    @records = records
    @enum = enumerator
  end

  def each
    @enum.each {|i| yield i }
  end

  def generate
    @enum.to_a.join
  end

  private

  def formats
    {}
  end

  def fields
    raise NotImplementedError, 'Subclasses must implement #fields'
  end

  def csv_row(record)
    fields.collect do |field|
      format(record.send(field))
    end
  end

  def format(value)
    formatted_value = formats.fetch(value.class, value)
    if formatted_value.respond_to?(:call)
      formatted_value = formatted_value.call(value)
    end
    formatted_value
  end

  private

  def enumerator
    Enumerator.new do |y|
      y << CSV.generate_line(fields)
      each_record do |record|
        y << CSV.generate_line(csv_row(record))
      end
    end
  end

  def each_record(&block)
    if @records.respond_to?(:find_each)
      @records.find_each(&block)
    else
      @records.each(&block)
    end
  end
end
