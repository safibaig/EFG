require 'spec_helper'

describe 'satisfy lender demand' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  let(:loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_user.lender) }
  before { login_as(current_user, scope: :user) }

  it 'works' do
    visit loan_path(loan)
    click_link 'Lender Demand Satisfied'

    fill_in :date_of_change, '28/3/13'
    click_button 'Submit'

    loan.reload
    loan.state.should == Loan::Guaranteed
    loan.modified_by.should == current_user

    loan_change = loan.loan_changes.last!
    loan_change.change_type.should == ChangeType::LenderDemandSatisfied
    loan_change.created_by.should == current_user
    loan_change.date_of_change.should == Date.new(2013, 3, 28)
    loan_change.modified_date.should == Date.today

    should_log_loan_state_change(loan, Loan::Guaranteed, 9, current_user)
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Lender Demand Satisfied'
    click_button 'Submit'

    loan.reload.state.should == Loan::LenderDemand
  end

  private
    def fill_in(attribute, value)
      page.fill_in "loan_satisfy_lender_demand_#{attribute}", with: value
    end
end
