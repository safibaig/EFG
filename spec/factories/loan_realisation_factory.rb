FactoryGirl.define do
  factory :loan_realisation do
    realisation_statement
    realised_loan { FactoryGirl.create(:loan) }
  end
end
