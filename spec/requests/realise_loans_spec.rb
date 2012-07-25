require 'spec_helper'

describe 'Realise loans' do

  let(:current_user) { FactoryGirl.create(:cfe_user) }

  let!(:lender1) { FactoryGirl.create(:lender, name: 'Hayes Inc') }

  let!(:loan1) { FactoryGirl.create(:loan, :recovered, reference: 'BSPFDNH-01', lender: lender1, settled_on: Date.new(2009)) }

  let!(:recovery1) { FactoryGirl.create(:recovery, loan: loan1, recovered_on: Date.new(2011, 2, 20)) }

  before(:each) do
    login_as(current_user, scope: :user)
    visit root_path
    click_link 'Recoveries statement received'
  end

  it 'should realise recovered loans' do
    # setup loans

    lender2 = FactoryGirl.create(:lender, name: 'Carroll-Cronin')

    loan2 = FactoryGirl.create(:loan, :recovered, reference: '3PEZRGB-01', lender: lender1, settled_on: Date.new(2009))
    loan3 = FactoryGirl.create(:loan, :recovered, reference: 'LOGIHLJ-02', lender: lender1, settled_on: Date.new(2009))
    loan5 = FactoryGirl.create(:loan, reference: 'HJD4JF8-01', lender: lender2, settled_on: Date.new(2009))

    recovery2 = FactoryGirl.create(:recovery, loan: loan2, recovered_on: Date.new(2011, 2, 20))
    recovery3 = FactoryGirl.create(:recovery, loan: loan3, recovered_on: Date.new(2012, 5, 5))
    recovery5 = FactoryGirl.create(:recovery, loan: loan5, recovered_on: Date.new(2012, 5, 5))

    # test

    select_loans

    page.should have_content('BSPFDNH-01')
    page.should have_content('3PEZRGB-01')
    page.should_not have_content('LOGIHLJ-02') # loan after quarter cut off date
    page.should_not have_content('HJD4JF8-01') # loan belongs to different lender

    within "#recovery_#{recovery1.id}" do
      check 'realisation_statement[recoveries_to_be_realised_ids][]'
    end

    within "#recovery_#{recovery2.id}" do
      check 'realisation_statement[recoveries_to_be_realised_ids][]'
    end

    click_button 'Realise Loans'

    page.should have_content('The following loans have been realised')
    page.should have_content(loan1.reference)
    page.should have_content(loan2.reference)
    page.should_not have_content(loan3.reference)
    page.should_not have_content(loan5.reference)

    loan1.reload.state.should == Loan::Realised
    loan2.reload.state.should == Loan::Realised
    loan3.reload.state.should == Loan::Recovered
    loan5.reload.state.should == Loan::Eligible
  end

  it 'should validate loans have been selected' do
    select lender1.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select 'March', from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: '2011'
    fill_in 'realisation_statement_received_on', with: '20/05/2011'
    click_button 'Select Loans'

    click_button 'Realise Loans'

    page.should have_content('No recoveries were selected.')
  end

  it 'should show error text when there are no loans to recover' do
    loan = FactoryGirl.create(:loan, :recovered, id: 1, recovery_on: Date.new(2011, 2, 20))

    select loan.lender.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select 'March', from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: '2010'
    fill_in 'realisation_statement_received_on', with: '20/05/2010'
    click_button 'Select Loans'

    page.should have_content('There are no recoveries to realise.')
  end

  it 'can export loan data as CSV' do
    select_loans

    click_button "Export CSV"

    page.current_url.should == select_loans_realise_loans_url(format: 'csv')
  end

  private

  def select_loans
    select lender1.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select 'March', from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: '2011'
    fill_in 'realisation_statement_received_on', with: '20/05/2011'
    click_button 'Select Loans'
  end

end
