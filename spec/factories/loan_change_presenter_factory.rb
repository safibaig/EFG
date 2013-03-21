FactoryGirl.define do
  factory :loan_change_presenter do
    association :created_by, factory: :lender_user
    date_of_change Date.new
    loan

    factory :repayment_duration_loan_change_presenter, class: RepaymentDurationLoanChangePresenter do
      added_months 3
    end
  end
end
