FactoryGirl.define do
  factory :loan_eligibility_check do
    viable_proposition 'true'
    would_you_lend 'true'
    collateral_exhausted 'true'
    amount '12345'
    lender_cap_id '1'
    repayment_duration({ years: '1', months: '6' })
    turnover '12345'
    trading_date '31/1/2011'
    sic_code '12345'
    loan_category_id '1'
    reason_id '1'
    previous_borrowing 'true'
    private_residence_charge_required 'false'
    personal_guarantee_required 'true'

    initialize_with {
      new(FactoryGirl.build(:loan))
    }
  end
end
