require 'spec_helper'

describe 'data correction' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }
  let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, amount: Money.new(5_000_00)) }

  describe 'creation' do
    [Loan::Guaranteed, Loan::LenderDemand, Loan::Demanded].each do |state|
      it "is navigable from #{state} state" do
        loan.update_attribute :state, state
        visit loan_path(loan)
        click_link 'Data Correction'
      end
    end

    it 'does not continue with nothing inputted' do
      visit loan_path(loan)
      click_link 'Data Correction'
      click_button 'Submit'
      page.should have_selector('.errors-on-base')
    end

    it do
      visit loan_path(loan)
      click_link 'Data Correction'

      fill_in 'amount', '6000'
      click_button 'Submit'

      loan_change = loan.loan_changes.last!
      loan_change.change_type_id.should == '9'
      loan_change.old_amount.should == Money.new(5_000_00)
      loan_change.amount.should == Money.new(6_000_00)
      loan_change.date_of_change.should == Date.current
      loan_change.modified_date.should == Date.current
      loan_change.created_by.should == current_user

      loan.reload
      loan.amount.should == Money.new(6_000_00)
      loan.modified_by.should == current_user
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "loan_change_#{attribute}", with: value
    end
end
