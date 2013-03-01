require 'active_model/model'

class BaseLoanReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  def self.date_attribute(*attributes)
    attributes.each do |attribute|

      attr_reader attribute

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
end
