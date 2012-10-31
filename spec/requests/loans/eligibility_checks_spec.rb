require 'spec_helper'

describe 'eligibility checks' do
  let(:lender) { FactoryGirl.create(:lender, :with_lending_limit) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: lender) }
  let!(:sic_code) { FactoryGirl.create(:sic_code) }

  before(:each) do
    ActionMailer::Base.deliveries.clear
    login_as(current_user, scope: :user)
  end

  it 'creates a loan from valid eligibility values' do
    visit root_path
    click_link 'New Loan Application'

    fill_in_valid_eligibility_check_details(lender)

    expect {
      click_button 'Check'
    }.to change(Loan, :count).by(1)

    loan = Loan.last

    current_url.should == loan_eligibility_decision_url(loan.id)

    loan.lender.should == lender
    loan.state.should == Loan::Eligible
    loan.viable_proposition.should be_true
    loan.would_you_lend.should be_true
    loan.collateral_exhausted.should be_true
    loan.amount.should == Money.new(5000089)
    loan.lending_limit.should be_instance_of(LendingLimit)
    loan.repayment_duration.should == MonthDuration.new(30)
    loan.turnover.should == Money.new(123456789)
    loan.trading_date.should == Date.new(2012, 1, 31)
    loan.sic_code.should == sic_code.code
    loan.loan_category_id.should == 2
    loan.reason_id.should == LoanReason.active.first.id
    loan.previous_borrowing.should be_true
    loan.private_residence_charge_required.should be_false
    loan.personal_guarantee_required.should be_false
    loan.loan_scheme.should == Loan::EFG_SCHEME
    loan.loan_source.should == Loan::SFLG_SOURCE
    loan.created_by.should == current_user
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Eligible, 1, current_user)

    # email eligibility decision

    # with invalid email
    fill_in :eligibility_decision_email, with: 'wrong'
    click_button "Send"

    page.should have_content("is invalid")

    # with valid email
    fill_in :eligibility_decision_email, with: 'joe@example.com'
    click_button "Send"

    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.should == [ 'joe@example.com' ]

    current_path.should == loan_path(loan)
    page.should have_content("Your email was sent successfully")
  end

  it 'does not create an invalid loan' do
    visit root_path
    click_link 'New Loan Application'

    expect {
      click_button 'Check'
    }.not_to change(Loan, :count)

    current_path.should == '/loans/eligibility_check'
  end

  it 'displays ineligibility reasons for a reject loan' do
    visit root_path
    click_link 'New Loan Application'

    fill_in_valid_eligibility_check_details(lender)
    # make loan fail eligibility check
    fill_in :loan_eligibility_check_amount, with: '6000000'

    expect {
      click_button 'Check'
    }.to change(Loan, :count).by(1)

    loan = Loan.last

    current_url.should == loan_eligibility_decision_url(loan.id)

    loan.state.should == Loan::Rejected
    loan.ineligibility_reasons.count.should == 1
    loan.ineligibility_reasons.last.reason.should == I18n.t('eligibility_check.attributes.amount.invalid')
    page.should have_content(I18n.t('eligibility_check.attributes.amount.invalid'))

    # email eligibility decision

    fill_in :eligibility_decision_email, with: 'joe@example.com'
    click_button "Send"

    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.should == [ 'joe@example.com' ]
    emails.first.body.should include(loan.ineligibility_reasons.first.reason)

    current_path.should == loan_path(loan)
    page.should have_content("Your email was sent successfully")
  end
end
