require 'csv'

class BaseCsvExport

  def initialize(records)
    @records = records
  end

  def generate
    CSV.generate do |csv|
      csv << fields
      @records.each do |record|
        csv << csv_row(record)
      end
    end
  end

  private

  def formats
    raise NotImplementedError, 'Define in sub-class'
  end

  def fields
    raise NotImplementedError, 'Define in sub-class'
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

end
