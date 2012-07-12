FactoryGirl.define do
  factory :loan_realisation do
    realisation_statement
    realised_loan { FactoryGirl.create(:loan) }
    association :created_by, factory: :user
    realised_amount Money.new(1_000_00)
  end
end
