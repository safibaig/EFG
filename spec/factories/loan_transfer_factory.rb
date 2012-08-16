FactoryGirl.define do
  factory :loan_transfer, class: LoanTransfer::Base do
    amount 1000000
    new_amount 800000
    reference "D54QT9C+01"
    declaration_signed 'true'
    lender

    factory :sflg_loan_transfer, class: LoanTransfer::Sflg do
      facility_letter_date '20/05/2011'
    end

    factory :legacy_sflg_loan_transfer, class: LoanTransfer::LegacySflg do
      initial_draw_date { Date.today }
    end

    initialize_with {
      loan = FactoryGirl.create(:loan, :guaranteed)
      new(loan)
    }
  end
end
