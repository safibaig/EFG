FactoryGirl.define do
  factory :update_loan_lending_limit do
    ignore do
      association :loan, factory: [:loan, :completed]
    end

    initialize_with do
      new(loan)
    end

    new_lending_limit_id { FactoryGirl.create(:lending_limit, :active, lender: loan.lender).id }
  end
end
