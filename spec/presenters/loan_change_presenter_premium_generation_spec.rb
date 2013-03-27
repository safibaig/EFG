require 'spec_helper'

describe LoanChangePresenter, 'next premium collection values' do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, repayment_duration: 60) }
  let(:presenter) {
    LoanChangePresenter.new(loan).tap do |presenter|
      presenter.created_by = loan.modified_by
      presenter.date_of_change = Date.today
    end
  }

  before do
    loan.initial_draw_change.update_column(:date_of_change, Date.new(2010, 1, 15))
  end

  it 'calculates correctly when within the first month' do
    Timecop.freeze(2010, 1, 1) do
      presenter.next_premium_cheque_month.should == '04/2010'
      presenter.repayment_duration_at_next_premium.should == 57
    end
  end

  it 'calculates correctly in the month of a collection' do
    Timecop.freeze(2013, 1, 15) do
      presenter.next_premium_cheque_month.should == '04/2013'
      presenter.repayment_duration_at_next_premium.should == 21
    end
  end

  it 'calculates correctly a month after a collection' do
    Timecop.freeze(2013, 2, 15) do
      presenter.next_premium_cheque_month.should == '04/2013'
      presenter.repayment_duration_at_next_premium.should == 21
    end
  end

  it 'calculates correctly a day before a collection month' do
    Timecop.freeze(2013, 3, 31) do
      presenter.next_premium_cheque_month.should == '04/2013'
      presenter.repayment_duration_at_next_premium.should == 21
    end
  end
end
