require 'active_model/model'

class BaseLoanReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  def self.date_attribute(*attributes)
    attributes.each do |attribute|

      define_method(attribute) do
        value = instance_variable_get "@#{attribute}"
        QuickDateFormatter.format(value)
      end

      define_method("#{attribute}=") do |value|
        instance_variable_set "@#{attribute}", QuickDateFormatter.parse(value)
      end

    end
  end

  def count
    @count ||= loans.count
  end

  def loans
    raise NotImplementedError, "Define in sub-class"
  end

  private

  # return ActiveRecord query array
  # e.g. ["loans.facility_letter_date >= ? AND loans.state = ?", Date Object, 'Guaranteed']
  def query_conditions
    conditions = []
    values = []

    query_conditions_mapping.each do |field, condition|
      value = send(field)
      next if value.blank?
      conditions << condition
      values << value
    end

    [conditions.join(" AND "), *values]
  end

  def query_conditions_mapping
    raise NotImplementedError, "Define in sub-class"
  end

end
