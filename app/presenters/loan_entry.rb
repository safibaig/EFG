class LoanEntry
  include LoanPresenter

  attribute :viable_proposition, read_only: true
  attribute :would_you_lend, read_only: true
  attribute :collateral_exhausted, read_only: true
  attribute :lender_cap_id, read_only: true
  attribute :sic_code, read_only: true
  attribute :loan_category_id, read_only: true
  attribute :reason_id, read_only: true
  attribute :previous_borrowing, read_only: true
  attribute :private_residence_charge_required, read_only: true
  attribute :personal_guarantee_required, read_only: true
  attribute :amount, read_only: true
  attribute :turnover, read_only: true
  attribute :repayment_duration, read_only: true
  attribute :trading_date, read_only: true

  attribute :declaration_signed
  attribute :business_name
  attribute :trading_name
  attribute :company_registration
  attribute :postcode
  attribute :non_validated_postcode
  attribute :branch_sortcode
  attribute :generic1
  attribute :generic2
  attribute :generic3
  attribute :generic4
  attribute :generic5
  attribute :town
  attribute :interest_rate_type_id
  attribute :interest_rate
  attribute :fees
  attribute :state_aid_is_valid

  # Don't really know what these fields are yet or how they are calculated.
  attr_accessor :legal_form, :state_aid_value
end
