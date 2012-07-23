FactoryGirl.define do
  factory :loan_entry do
    declaration_signed true
    business_name "Widgets PLC"
    legal_form_id 1
    interest_rate_type_id 1
    interest_rate 5.00
    fees 1000
    repayment_frequency_id 1
    postcode 'EC1R 4RP'
    maturity_date '01/01/2012'

    initialize_with {
      loan = FactoryGirl.build(:loan, :with_state_aid_calculation)
      new(loan)
    }

    factory :loan_entry_type_b do
      loan_security_types [1]
      security_proportion 25.0

      initialize_with {
        loan = FactoryGirl.build(:loan, :with_state_aid_calculation, loan_category_id: 2)
        new(loan)
      }
    end

    factory :loan_entry_type_c do
      original_overdraft_proportion 20.0
      refinance_security_proportion 15.0

      initialize_with {
        loan = FactoryGirl.build(:loan, :with_state_aid_calculation, loan_category_id: 3)
        new(loan)
      }
    end

    factory :loan_entry_type_d do
      refinance_security_proportion 20.0
      current_refinanced_value 10000.00
      final_refinanced_value 20000.00

      initialize_with {
        loan = FactoryGirl.build(:loan, :with_state_aid_calculation, loan_category_id: 4)
        new(loan)
      }
    end

    factory :loan_entry_type_e do
      overdraft_limit 1000000
      overdraft_maintained true

      initialize_with {
        loan = FactoryGirl.build(:loan, :with_state_aid_calculation, loan_category_id: 5)
        new(loan)
      }
    end

    factory :loan_entry_type_f do
      invoice_discount_limit 1000000
      debtor_book_coverage 5.0
      debtor_book_topup 20.0

      initialize_with {
        loan = FactoryGirl.build(:loan, :with_state_aid_calculation, loan_category_id: 6)
        new(loan)
      }
    end

  end
end
