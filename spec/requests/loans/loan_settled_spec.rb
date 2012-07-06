require 'spec_helper'

describe "loan settled" do
  let(:current_user) { FactoryGirl.create(:cfe_user) }
  before { login_as(current_user, scope: :user) }

  it "setting loans" do
    lender1 = FactoryGirl.create(:lender, name: 'Hayes Inc')
    lender2 = FactoryGirl.create(:lender, name: 'Carroll-Cronin')

    loan1 = FactoryGirl.create(:loan, :demanded, id: 1, reference: 'BSPFDNH-01', lender: lender1)
    loan2 = FactoryGirl.create(:loan, :demanded, id: 2, reference: '3PEZRGB-01', lender: lender1)
    loan3 = FactoryGirl.create(:loan, :demanded, id: 3, reference: 'LOGIHLJ-02', lender: lender1)
    loan4 = FactoryGirl.create(:loan, id: 4, reference: 'MF6XT4Z-01', lender: lender1)
    loan5 = FactoryGirl.create(:loan, id: 5, reference: 'HJD4JF8-01', lender: lender2)

    visit(root_path)
    click_link 'Invoice Received'

    select 'Hayes Inc', from: 'invoice[lender_id]'
    fill_in 'invoice[reference]', with: '2006-SADHJ'
    select 'December', from: 'invoice[period_covered_quarter]'
    fill_in 'invoice[period_covered_year]', with: '2011'
    fill_in 'invoice[received_on]', with: '06/01/2012'

    click_button 'Select Loans'

    page.should have_content('BSPFDNH-01')
    page.should have_content('3PEZRGB-01')
    page.should have_content('LOGIHLJ-02')
    page.should_not have_content('MF6XT4Z-01')
    page.should_not have_content('HJD4JF8-01')

    within('#loan_1') do
      check('invoice[settled_loan_ids][]')
    end

    within('#loan_3') do
      check('invoice[settled_loan_ids][]')
    end

    click_button 'Settle Loans'

    invoice = Invoice.last
    invoice.lender.should == lender1
    invoice.reference.should == '2006-SADHJ'
    invoice.period_covered_quarter.should == 'December'
    invoice.period_covered_year.should == '2011'
    invoice.received_on.should == Date.new(2012, 01, 06)
    invoice.created_by.should == current_user

    invoice.settled_loans.should =~ [loan1, loan3]

    loan1.reload; loan3.reload
    loan1.state.should == Loan::Settled
    loan3.state.should == Loan::Settled
  end
end
