require 'spec_helper'

describe RepaymentDurationLoanChange do
  it_behaves_like 'LoanChangePresenter'

  describe 'validations' do
    context '#added_months' do
      let(:presenter) { FactoryGirl.build(:repayment_duration_loan_change) }

      it 'is required' do
        presenter.added_months = nil
        presenter.should_not be_valid
      end

      it 'must not be zero' do
        presenter.added_months = 0
        presenter.should_not be_valid
      end

      [
        RepaymentFrequency::Annually,
        RepaymentFrequency::SixMonthly,
        RepaymentFrequency::Quarterly
      ].each do |repayment_frequency|
        context "for #{repayment_frequency.name} repayment_frequency" do
          before do
            presenter.loan.update_column :repayment_frequency_id, repayment_frequency.id
          end

          it 'ensures added_months are in valid chunks' do
            presenter.added_months = 2
            presenter.should_not be_valid

            presenter.added_months = repayment_frequency.months_per_repayment_period
            presenter.should be_valid
          end
        end
      end

      [
        RepaymentFrequency::Monthly,
        RepaymentFrequency::InterestOnly
      ].each do |repayment_frequency|
        context "for #{repayment_frequency.name} repayment_frequency" do
          before do
            presenter.loan.update_column :repayment_frequency_id, repayment_frequency.id
          end

          it 'works' do
            presenter.added_months = 2
            presenter.should be_valid
          end
        end
      end

      context 'calculated #repayment_duration_at_next_premium' do
        let(:loan) { FactoryGirl.create(:loan, :guaranteed, repayment_duration: 24) }
        let(:presenter) { FactoryGirl.build(:repayment_duration_loan_change, loan: loan) }

        before do
          loan.initial_draw_change.update_column(:date_of_change, Date.new(2010, 1, 1))

          # The month of second quarter collection.
          Timecop.freeze(2010, 4, 1)
        end

        after do
          Timecop.return
        end

        it 'must be positive' do
          presenter.added_months = -18
          presenter.should_not be_valid

          presenter.added_months = -17
          presenter.should be_valid
        end
      end

      context 'calculated #repayment_duration' do
        let(:presenter) { FactoryGirl.build(:repayment_duration_loan_change, loan: loan) }

        before do
          loan.initial_draw_change.update_column(:date_of_change, Date.new(2010, 1, 1))

          # One month after initial draw date.
          Timecop.freeze(2010, 2, 1)
        end

        after do
          Timecop.return
        end

        context 'for an EFG loan' do
          let(:loan) { FactoryGirl.create(:loan, :guaranteed, repayment_duration: 60, maturity_date: Date.new(2015, 1, 1)) }

          it 'must be more than zero months' do
            presenter.added_months = -60
            presenter.should_not be_valid
          end

          it 'must be at least 3 months' do
            presenter.added_months = -58
            presenter.should_not be_valid
          end

          it 'must be no more than 120 months' do
            presenter.added_months = 61
            presenter.should_not be_valid

            presenter.added_months = 60
            presenter.should be_valid
          end
        end

        context 'for a SFLG loan (with no category)' do
          let(:loan) { FactoryGirl.create(:loan, :sflg, :guaranteed, loan_category_id: nil, repayment_duration: 60) }

          it 'must be more than zero months' do
            presenter.added_months = -60
            presenter.should_not be_valid
          end

          it 'must be at least 24 months' do
            presenter.added_months = -37
            presenter.should_not be_valid

            presenter.added_months = -36
            presenter.should be_valid
          end

          it 'must be no more than 120 months' do
            presenter.added_months = 61
            presenter.should_not be_valid

            presenter.added_months = 60
            presenter.should be_valid
          end
        end

        context 'for a transferred loan' do
          let(:loan) { FactoryGirl.create(:loan, :transferred, repayment_duration: 60) }

          it 'must be more than zero months' do
            presenter.added_months = -60
            presenter.should_not be_valid
          end
        end
      end
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: Date.new(2015, 3, 2), repayment_duration: 60) }
    let(:presenter) { FactoryGirl.build(:repayment_duration_loan_change, created_by: user, loan: loan) }

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
