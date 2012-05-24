require 'active_model/model'

class LoanEntry
  include ActiveModel::Model

  READ_ONLY_ATTRIBUTES = [:viable_proposition, :would_you_lend,
                          :collateral_exhausted, :lender_cap_id, :sic_code,
                          :loan_category_id, :reason_id, :previous_borrowing,
                          :private_residence_charge_required,
                          :personal_guarantee_required, :amount, :turnover,
                          :repayment_duration]

  delegate *READ_ONLY_ATTRIBUTES, to: :loan

  ATTRIBUTES = [:declaration_signed, :business_name, :trading_name,
                :company_registration, :postcode, :non_validated_postcode,
                :branch_sortcode, :generic1, :generic2, :generic3, :generic4,
                :generic5, :town, :interest_rate_type_id, :interest_rate,
                :fees, :state_aid_is_valid]


  ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :loan
  end
  delegate :errors, :save, :trading_date, to: :loan

  attr_reader :loan

  def initialize(loan, attributes = {})
    @loan = loan
    super(attributes)
  end

  # Don't really know what these fields are yet or how they are calculated.
  attr_accessor :legal_form, :state_aid_value
end
