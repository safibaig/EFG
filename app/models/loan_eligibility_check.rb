require 'active_model/model'

class LoanEligibilityCheck
  include ActiveModel::Model

  ATTRIBUTES = [:viable_proposition, :would_you_lend, :collateral_exhausted,
                :amount, :lender_cap, :turnover,
                :trading_date, :sic_code, :loan_category, :reason,
                :previous_borrowing, :private_residence_charge_required,
                :personal_guarantee_required]

  ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :loan
  end
  delegate :errors, :save, to: :loan
  delegate :repayment_duration, to: :loan

  attr_reader :loan

  def initialize(*)
    @loan = Loan.new
    super
  end

  def repayment_duration
    duration = loan.repayment_duration.to_i
    { years: duration / 12, months: duration % 12 }
  end

  def repayment_duration=(hash)
    years = hash.fetch(:years, 0).to_i
    months = hash.fetch(:months, 0).to_i
    loan.repayment_duration = (years * 12) + months
  end
end
