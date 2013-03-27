require 'spec_helper'

describe LumpSumRepaymentLoanChangePresenter do
  it_behaves_like 'LoanChangePresenter'

  describe 'validations' do
    context '#lump_sum_repayment' do
      let(:loan) { FactoryGirl.create(:loan, :guaranteed, amount: Money.new(10_000_00)) }
      let(:presenter) { FactoryGirl.build(:lump_sum_repayment_loan_change_presenter, loan: loan) }

      it 'is required' do
        presenter.lump_sum_repayment = nil
        presenter.should_not be_valid
      end

      it 'must be greater than zero' do
        presenter.lump_sum_repayment = '0'
        presenter.should_not be_valid
      end

      it 'must not be greater than the amount available for the loan' do
        loan.stub!(:cumulative_lump_sum_amount).and_return(Money.new(5_000_00))

        presenter.lump_sum_repayment = '5,000.01'
        presenter.should_not be_valid

        presenter.lump_sum_repayment = '5,000'
        presenter.should be_valid
      end
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, repayment_duration: 60) }
    let(:presenter) { FactoryGirl.build(:lump_sum_repayment_loan_change_presenter, created_by: user, loan: loan) }

    context 'success' do
      before do
        loan.initial_draw_change.update_column :date_of_change, Date.new(2013, 2)
      end

      it 'creates a LoanChange, a PremiumSchedule, and updates the loan' do
        presenter.lump_sum_repayment = Money.new(1_000_00)

        Timecop.freeze(2013, 3, 1) do
          presenter.save.should == true
        end

        loan_change = loan.loan_changes.last!
        loan_change.change_type.should == ChangeType::LumpSumRepayment
        loan_change.lump_sum_repayment.should == Money.new(1_000_00)
        loan_change.created_by.should == user

        loan.reload
        loan.modified_by.should == user
        loan.cumulative_lump_sum_amount.should == Money.new(1_000_00)

        premium_schedule = loan.premium_schedules.last!
        premium_schedule.premium_cheque_month.should == '05/2013'
        premium_schedule.repayment_duration.should == 57
      end
    end

    context 'failure' do
      it 'does not update loan' do
        presenter.lump_sum_repayment = nil
        presenter.save.should == false

        loan.reload
        loan.modified_by.should_not == user
      end
    end
  end
end
