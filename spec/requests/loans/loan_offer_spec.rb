require 'spec_helper'

describe 'loan offer' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :completed, lender: current_lender) }
  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Offer Loan'

    check 'facility_letter_sent'
    fill_in 'facility_letter_date', '24/5/2012'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Offered
    loan.facility_letter_date.should == Date.new(2012, 5, 24)
    loan.facility_letter_sent.should == true
  end

  it 'does not continue with invalid values' do
    pending "Don't know what makes this form invalid yet."
  end

  private
    def check(attribute)
      page.check "loan_offer_#{attribute}"
    end

    def fill_in(attribute, value)
      page.fill_in "loan_offer_#{attribute}", with: value
    end
end
