FactoryGirl.define do
  factory :loan do
    viable_proposition true
    would_you_lend true
    collateral_exhausted true
    amount 12345
    lender_cap 1
    repayment_duration 24
    turnover 12345
    trading_date 2.years.ago
    sic_code '12345'
    loan_category 1
    reason 1
    previous_borrowing true
    private_residence_charge_required true
    personal_guarantee_required true
  end
end
