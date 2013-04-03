require 'spec_helper'

describe ReprofileDrawsLoanChange do
  it_behaves_like 'LoanChangePresenter'

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, repayment_duration: 60) }
    let(:presenter) { FactoryGirl.build(:reprofile_draws_loan_change, created_by: user, loan: loan) }

    before do
      loan.initial_draw_change.update_column :date_of_change, Date.new(2010, 1)
    end

    it 'creates a LoanChange, a PremiumSchedule, and updates the loan' do
      Timecop.freeze(2013, 3, 1) do
        presenter.save.should == true
      end

      loan_change = loan.loan_changes.last!
      loan_change.change_type.should == ChangeType::ReprofileDraws
      loan_change.created_by.should == user

      loan.reload
      loan.modified_by.should == user

      premium_schedule = loan.premium_schedules.last!
      premium_schedule.premium_cheque_month.should == '04/2013'
      premium_schedule.repayment_duration.should == 21
    end
  end
end
