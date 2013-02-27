require 'spec_helper'

describe LoanAlerts::NotClosedLoanAlert do
  let(:lender) { FactoryGirl.create(:lender) }
  let(:not_closed) { LoanAlerts::NotClosedLoanAlert.new(lender) }

  describe '#loans' do
    let!(:loan1) { FactoryGirl.create(:loan, :sflg, :guaranteed, lender: lender, maturity_date: 22.weeks.ago.to_date) }
    let!(:loan2) { FactoryGirl.create(:loan, :sflg, :guaranteed, lender: lender, maturity_date: 21.weeks.ago.to_date) }
    let!(:loan3) { FactoryGirl.create(:loan, :sflg, :guaranteed, lender: lender, maturity_date: 20.weeks.ago.to_date) }
    let!(:loan4) { FactoryGirl.create(:loan, :efg,  :guaranteed, lender: lender, maturity_date: 12.weeks.ago.to_date) }
    let!(:loan5) { FactoryGirl.create(:loan, :efg,  :guaranteed, lender: lender, maturity_date: 11.weeks.ago.to_date) }
    let!(:loan6) { FactoryGirl.create(:loan, :efg,  :guaranteed, lender: lender, maturity_date: 10.weeks.ago.to_date) }
    let!(:loan7) { FactoryGirl.create(:loan, :efg,  :guaranteed,                 maturity_date: 10.weeks.ago.to_date) }

    it 'fetches the loans from both guaranteed and offered, and sorts by maturity date' do
      not_closed.loans.should == [loan1, loan2, loan3, loan4, loan5, loan6]
    end
  end
end
