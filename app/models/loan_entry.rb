require 'active_model/model'

class LoanEntry
  include ActiveModel::Model

  def initialize(loan)
    @loan = loan
  end

  attr_accessor :declaration_signed, :business_name, :legal_form, :trading_name, :company_registration, :postcode, :branch_sortcode, :generic1, :generic2, :generic3, :generic4, :generic5, :non_validated_postcode, :town, :interest_rate_type_id, :interest_rate, :fees

  attr_accessor :total_value_state_aid, :state_aid_value

  attr_reader :loan
  delegate :turnover, :trading_date, :amount, :lender_cap_id, :repayment_duration, :sic_code, :loan_category_id, :reason_id, :private_residence_charge_required, :personal_guarantee_required, :viable_proposition, :would_you_lend, :collateral_exhausted, :previous_borrowing, to: :loan
end
