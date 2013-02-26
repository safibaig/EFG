class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return false if value.nil?
    unless value.match(/^(?:[a-z0-9_\.\+-]*)[a-z0-9]@(?:[a-z0-9_-]+[a-z0-9]\.){1,3}[a-z]+$/i)
      record.errors[attribute] << (options[:message] || "is not a valid email address")
    end
  end
end
