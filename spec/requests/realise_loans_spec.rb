require 'spec_helper'

describe 'Realise loans' do

  let(:current_user) { FactoryGirl.create(:cfe_user) }

  let!(:loan) { FactoryGirl.create(:loan, :recovered, updated_at: Date.parse('20-02-2011')) }

  before do
    login_as(current_user, scope: :user)
  end

  it 'should realise recovered loans' do
    visit root_path
    click_link 'Recoveries statement received'

    select loan.lender.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select 'March', from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: '2011'
    fill_in 'realisation_statement_received_on', with: '20/05/2011'
    click_button 'Select Loans'

    check 'realisation_statement[loans_to_be_realised_ids][]'
    click_button 'Realise Loans'

    page.should have_content('The following loans have been realised')
    page.should have_content(loan.reference)

    loan.reload.state.should == Loan::Realised
  end

end
