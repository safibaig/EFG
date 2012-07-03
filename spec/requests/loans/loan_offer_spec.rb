require 'spec_helper'

describe 'loan offer' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :completed, lender: current_lender) }
  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Offer Scheme Facility'

    choose_radio_button 'facility_letter_sent', true
    fill_in 'facility_letter_date', '24/5/12'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Offered
    loan.facility_letter_date.should == Date.new(2012, 5, 24)
    loan.facility_letter_sent.should == true
  end

  it 'does not continue with invalid values' do
    visit new_loan_offer_path(loan)

    loan.state.should == Loan::Completed
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == "/loans/#{loan.id}/offer"
  end

  private
  def choose_radio_button(attribute, value)
    choose "loan_offer_#{attribute}_#{value}"
  end

  def fill_in(attribute, value)
    page.fill_in "loan_offer_#{attribute}", with: value
  end
end
