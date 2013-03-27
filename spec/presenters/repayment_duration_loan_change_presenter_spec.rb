require 'spec_helper'

describe RepaymentDurationLoanChangePresenter do
  it_behaves_like 'LoanChangePresenter'

  describe 'validations' do
    context '#added_months' do
      let(:loan) { FactoryGirl.create(:loan, :guaranteed, repayment_duration: 24) }
      let(:presenter) { FactoryGirl.build(:repayment_duration_loan_change_presenter, loan: loan) }

      it 'is required' do
        presenter.added_months = nil
        presenter.should_not be_valid
      end

      it 'must not be zero' do
        presenter.added_months = 0
        presenter.should_not be_valid
      end

      context 'calculaing #repayment_duration' do
        it 'cannot be too short' do
          presenter.added_months = -22
          presenter.should_not be_valid
        end

        it 'cannot be too long' do
          presenter.added_months = 999
          presenter.should_not be_valid
        end
      end
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: Date.new(2015, 3, 2), repayment_duration: 60) }
    let(:presenter) { FactoryGirl.build(:repayment_duration_loan_change_presenter, created_by: user, loan: loan) }

    context 'success' do
      before do
        loan.initial_draw_change.update_column :date_of_change, Date.new(2010, 3, 2)
      end

      let(:loan_change) { loan.loan_changes.last! }

      it 'creates a LoanChange and updates the loan' do
        presenter.added_months = 3

        Timecop.freeze(2013, 3, 1) do
          presenter.save.should == true
        end

        loan_change.old_maturity_date.should == Date.new(2015, 3, 2)
        loan_change.maturity_date.should == Date.new(2015, 6, 2)
        loan_change.old_repayment_duration.should == 60
        loan_change.repayment_duration.should == 63
        loan_change.created_by.should == user

        loan.reload
        loan.repayment_duration.total_months.should == 63
        loan.maturity_date.should == Date.new(2015, 6, 2)
        loan.modified_by.should == user

        premium_schedule = loan.premium_schedules.last!
        premium_schedule.premium_cheque_month.should == '06/2013'
        premium_schedule.repayment_duration.should == 24
      end

      it 'stores the correct change_type when extending' do
        presenter.added_months = 3
        presenter.save.should == true

        loan_change.change_type.should == ChangeType::ExtendTerm
      end

      it 'stores the correct change_type when decreasing' do
        presenter.added_months = -3
        presenter.save.should == true

        loan_change.change_type.should == ChangeType::DecreaseTerm
      end
    end

    context 'failure' do
      before do
        presenter.added_months = nil
        presenter.save.should == false
      end

      it 'does not update loan' do
        loan.reload
        loan.repayment_duration.total_months.should == 60
        loan.maturity_date.should == Date.new(2015, 3, 2)
      end
    end
  end
end
