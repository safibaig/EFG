require 'spec_helper'

describe 'Realise loans' do

  let(:current_user) { FactoryGirl.create(:cfe_user) }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  it 'should realise recovered loans' do
    # setup loans

    lender1 = FactoryGirl.create(:lender, name: 'Hayes Inc')
    lender2 = FactoryGirl.create(:lender, name: 'Carroll-Cronin')

    loan1 = FactoryGirl.create(:loan, :recovered, id: 1, reference: 'BSPFDNH-01', lender: lender1, recovery_on: Date.new(2011, 2, 20))
    loan2 = FactoryGirl.create(:loan, :recovered, id: 2, reference: '3PEZRGB-01', lender: lender1, recovery_on: Date.new(2011, 2, 20))
    loan3 = FactoryGirl.create(:loan, :recovered, id: 3, reference: 'LOGIHLJ-02', lender: lender1, recovery_on: Date.new(2012, 5, 5))
    loan4 = FactoryGirl.create(:loan, id: 4, reference: 'MF6XT4Z-01', lender: lender1, recovery_on: Date.new(2011, 2, 20))
    loan5 = FactoryGirl.create(:loan, id: 5, reference: 'HJD4JF8-01', lender: lender2, recovery_on: Date.new(2012, 5, 5))

    # test

    visit root_path
    click_link 'Recoveries statement received'

    select loan1.lender.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select 'March', from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: '2011'
    fill_in 'realisation_statement_received_on', with: '20/05/2011'
    click_button 'Select Loans'

    page.should have_content('BSPFDNH-01')
    page.should have_content('3PEZRGB-01')
    page.should_not have_content('MF6XT4Z-01') # loan not recovered
    page.should_not have_content('LOGIHLJ-02') # loan after quarter cut off date
    page.should_not have_content('HJD4JF8-01') # loan belongs to different lender

    within('#loan_1') do
      check 'realisation_statement[loans_to_be_realised_ids][]'
    end

    within('#loan_2') do
      check 'realisation_statement[loans_to_be_realised_ids][]'
    end

    click_button 'Realise Loans'

    page.should have_content('The following loans have been realised')
    page.should have_content(loan1.reference)
    page.should have_content(loan2.reference)
    page.should_not have_content(loan3.reference)
    page.should_not have_content(loan4.reference)
    page.should_not have_content(loan5.reference)

    loan1.reload.state.should == Loan::Realised
    loan2.reload.state.should == Loan::Realised
    loan3.reload.state.should == Loan::Recovered
    loan4.reload.state.should == Loan::Eligible
    loan5.reload.state.should == Loan::Eligible
  end

  it 'should validate loans have been selected' do
    loan = FactoryGirl.create(:loan, :recovered, id: 1, recovery_on: Date.new(2011, 2, 20))

    visit root_path
    click_link 'Recoveries statement received'

    select loan.lender.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select 'March', from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: '2011'
    fill_in 'realisation_statement_received_on', with: '20/05/2011'
    click_button 'Select Loans'

    click_button 'Realise Loans'

    page.should have_content('No loans were selected.')
  end

  it 'should show error text when there are no loans to recover' do
    loan = FactoryGirl.create(:loan, :recovered, id: 1, recovery_on: Date.new(2011, 2, 20))

    visit root_path
    click_link 'Recoveries statement received'

    select loan.lender.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select 'March', from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: '2010'
    fill_in 'realisation_statement_received_on', with: '20/05/2010'
    click_button 'Select Loans'

    page.should have_content('There are no loans to realise.')
  end

end
