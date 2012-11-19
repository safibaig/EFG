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

  def fields
    raise NotImplementedError, 'Subclasses must implement #fields'
  end

  private

  def formats
    {}
  end

  def header
    fields.map { |field| t(field) }
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

  def enumerator
    Enumerator.new do |y|
      y << CSV.generate_line(header)
      each_record do |*args|
        row = csv_row(*args).to_a
        y << CSV.generate_line(row)
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

  def self.translation_scope
  end

  def translation_scope
    self.class.translation_scope
  end

  def t(key)
    if translation_scope
      I18n.t(key, scope: translation_scope)
    else
      key
    end
  end
end
