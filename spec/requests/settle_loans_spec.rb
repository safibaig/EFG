require 'spec_helper'

describe 'Settle loans' do

  let(:current_user) { FactoryGirl.create(:cfe_user) }

  let!(:loan) { FactoryGirl.create(:loan, :demanded) }

  before do
    login_as(current_user, scope: :user)
  end

  it 'should settle demanded loans' do
    visit root_path
    click_link 'Invoice Received'

    select loan.lender.name, from: 'invoice_lender_id'
    fill_in 'invoice_reference', with: "ABC123"
    select 'March', from: 'invoice_period_covered_quarter'
    fill_in 'invoice_period_covered_year', with: '2011'
    fill_in 'invoice_received_on', with: '20/05/2011'
    click_button 'Select Loans'

    check 'invoice[loans_to_be_settled_ids][]'
    click_button 'Settle Loans'

    page.should have_content('The following loans have been settled')
    page.should have_content(loan.reference)

    loan.reload.state.should == Loan::Settled
  end

end
