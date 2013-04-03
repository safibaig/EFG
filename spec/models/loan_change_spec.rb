# encoding: utf-8

require 'spec_helper'

describe LoanChange do
  it_behaves_like 'LoanModification'

  describe 'validations' do
    let(:loan_change) { FactoryGirl.build(:loan_change) }

    it 'requires a change_type_id' do
      loan_change.change_type_id = ''
      loan_change.should_not be_valid
    end

    it 'must have a valid change_type_id' do
      loan_change.change_type_id = ChangeType::DataCorrection.id
      loan_change.should_not be_valid
      loan_change.change_type_id = 'zzz'
      loan_change.should_not be_valid
    end

    it 'must not have a negative amount_drawn' do
      loan_change.amount_drawn = '-1'
      loan_change.should_not be_valid
    end

    it 'must not have a negative lump_sum_repayment' do
      loan_change.lump_sum_repayment = '-1'
      loan_change.should_not be_valid
    end

    context 'change types' do
      context '1 - business name' do
        it 'requires a business_name' do
          loan_change.change_type_id = ChangeType::BusinessName.id
          loan_change.business_name = ''
          loan_change.should_not be_valid
          loan_change.business_name = 'ACME'
          loan_change.should be_valid
        end
      end

      context '5 - Lender demand satisfied' do
        before do
          loan_change.change_type_id = ChangeType::LenderDemandSatisfied.id
          loan_change.amount_drawn = ''
          loan_change.lump_sum_repayment = ''
          loan_change.maturity_date = ''
        end

        it 'requires either amount_drawn, lump_sum_repayment or maturity_date' do
          loan_change.should_not be_valid
        end

        it 'is valid with amount_drawn' do
          loan_change.amount_drawn = '123'
          loan_change.should be_valid
        end

        it 'is valid with lump_sum_repayment' do
          loan_change.lump_sum_repayment = '123'
          loan_change.should be_valid
        end

        it 'is valid with maturity_date' do
          loan_change.maturity_date = '1/1/11'
          loan_change.should be_valid
        end
      end

      context '6 - Lump sum repayment' do
        let(:loan_change) { FactoryGirl.build(:loan_change, :reschedule) }

        before(:each) do
          loan_change.change_type_id = ChangeType::LumpSumRepayment.id
          loan_change.loan.stub!(:cumulative_drawn_amount).and_return(Money.new(30000_00))
        end

        it 'requires a lump_sum_repayment value' do
          loan_change.lump_sum_repayment = ''
          loan_change.should_not be_valid
          loan_change.lump_sum_repayment = '1,000'
          loan_change.should be_valid
        end

        it 'requires lump_sum_repayment + previous lump sum repayments to not be greater than amount drawn on the loan' do
          loan_change.loan.stub!(:cumulative_lump_sum_amount).and_return(Money.new(10000_00))

          loan_change.lump_sum_repayment = '20,001'
          loan_change.should_not be_valid
          loan_change.lump_sum_repayment = '20,000'
          loan_change.should be_valid
        end
      end

      context '7 - Record agreed draw' do
        before(:each) do
          loan_change.change_type_id = ChangeType::RecordAgreedDraw.id
        end

        it 'requires a amount_drawn' do
          loan_change.amount_drawn = ''
          loan_change.should_not be_valid
          loan_change.amount_drawn = '1,000'
          loan_change.should be_valid
        end

        it 'requires amount_drawn to not be greater than remaining amount not yet drawn on the loan' do
          loan_change.loan.stub!(:amount_not_yet_drawn).and_return(Money.new(9000_00))

          loan_change.amount_drawn = '10,000'
          loan_change.should_not be_valid
          loan_change.amount_drawn = '9,000'
          loan_change.should be_valid
        end
      end

      context 'a - Decrease term' do
        let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

        let(:loan_change) { FactoryGirl.build(:loan_change, :reschedule, loan: loan) }

        it 'requires a maturity_date' do
          loan_change.change_type_id = ChangeType::DecreaseTerm.id
          loan_change.maturity_date = ''
          loan_change.should_not be_valid
          loan_change.maturity_date = Date.new(2020)
          loan_change.should be_valid
        end
      end

      # 4 - extend term
      # a - decrease term
     [ChangeType::ExtendTerm.id, ChangeType::DecreaseTerm.id].each do |change_type_id|
        context change_type_id do
          let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

          let(:loan_change) { FactoryGirl.build(:loan_change, :reschedule, loan: loan) }

          let(:repayment_duration) { RepaymentDuration.new(loan) }

          let(:initial_draw_date) { loan.initial_draw_change.date_of_change }

          before(:each) do
            loan_change.change_type_id = change_type_id
          end

          it 'requires a maturity_date' do
            loan_change.maturity_date = ''
            loan_change.should_not be_valid
            loan_change.maturity_date = 10.years.from_now.to_date
            loan_change.should be_valid
          end

          context 'when SFLG loan with no loan category' do
            let(:loan) { FactoryGirl.create(:loan, :guaranteed, :sflg, loan_category_id: nil) }

            it 'requires maturity date to be at least 24 months after initial draw date' do
              loan_change.maturity_date = initial_draw_date.advance(months: 24) - 1.day
              loan_change.should_not be_valid

              loan_change.maturity_date = initial_draw_date.advance(months: 24)
              loan_change.should be_valid
            end

            it 'requires maturity date to not be more than 120 months after initial draw date' do
              loan_change.maturity_date = initial_draw_date.advance(months: 120, days: 1)
              loan_change.should_not be_valid

              loan_change.maturity_date = initial_draw_date.advance(months: 120)
              loan_change.should be_valid
            end
          end

          context 'when EFG loan' do
            it 'requires maturity date to be minimum loan term months (default 3) after initial draw date' do
              loan_change.maturity_date = initial_draw_date.advance(months: 3) - 1.day
              loan_change.should_not be_valid

              loan_change.maturity_date = initial_draw_date.advance(months: 3)
              loan_change.should be_valid
            end

            it 'requires maturity date to not exceed maximum loan term months (default 120) after initial draw date' do
              loan_change.maturity_date = initial_draw_date.advance(months: 120, days: 1)
              loan_change.should_not be_valid

              loan_change.maturity_date = initial_draw_date.advance(months: 120)
              loan_change.should be_valid
            end
          end

          context 'when transferred loan' do
            let(:loan) { FactoryGirl.create(:loan, :transferred) }

            it 'has no maturity date minimum months restriction' do
              loan_change.maturity_date = Date.today
              loan_change.should be_valid
            end
          end
        end
      end
    end

    context 'when state aid recalculation is required' do
      it 'should require state aid calculation attributes' do
        loan_change.change_type_id = ChangeType::CapitalRepaymentHoliday.id
        loan_change.should_not be_valid
        loan_change.premium_schedule_attributes = FactoryGirl.attributes_for(
          :rescheduled_premium_schedule, loan: loan_change.loan
        )
        loan_change.should be_valid
      end
    end
  end

  describe '#changes' do
    let(:loan_change) { FactoryGirl.build(:loan_change) }

    it 'contains only fields that have a value' do
      loan_change.old_business_name = 'Foo'
      loan_change.business_name = 'Bar'

      loan_change.changes.size.should == 1
      loan_change.changes.first[:attribute].should == 'business_name'
    end
  end

  describe '#save_and_update_loan' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, :lender_demand, business_name: 'ACME', maturity_date: Date.new(2020, 3, 2)) }
    let(:loan_change) {
      LoanChange.new do |loan_change|
        loan_change.created_by = user
        loan_change.date_of_change = Date.current
        loan_change.loan = loan
        loan_change.modified_date = Date.current
      end
    }
    let(:premium_schedule_attributes) { FactoryGirl.attributes_for(:rescheduled_premium_schedule, loan: loan) }

    context 'change types' do
      context '1 - business name' do
        before do
          loan_change.change_type_id = ChangeType::BusinessName.id
          loan_change.business_name = 'Foo'
        end

        it 'works' do
          loan_change.save_and_update_loan.should == true
          loan_change.old_business_name.should == 'ACME'

          loan.reload
          loan.business_name.should == 'Foo'
          loan.modified_by.should == user
          loan.state.should == Loan::Guaranteed

          state_change = loan.state_changes.last!
          state_change.event_id.should == 9
          state_change.state.should == Loan::Guaranteed
        end

        it 'does not update Loan#maturity_date' do
          loan_change.maturity_date = Date.new(2021, 4, 3)
          loan_change.save_and_update_loan.should == true
          loan_change.old_maturity_date.should == nil

          loan.reload
          loan.maturity_date.should == Date.new(2020, 3, 2)
        end
      end

      # 4 - extend term
      # a - decrease term
      %w(4 a).each do |change_type|
        context change_type do
          before do
            loan_change.loan.initial_draw_change.update_attribute(:date_of_change, Date.new(2015, 1, 31))

            loan_change.change_type_id = change_type
            loan_change.maturity_date = Date.new(2019, 4, 3)
            loan_change.premium_schedule_attributes = premium_schedule_attributes

            loan_change.save_and_update_loan
          end

          it 'stores old maturity date' do
            loan_change.old_maturity_date.should == Date.new(2020, 3, 2)
          end

          it 'stores old loan term' do
            loan_change.old_repayment_duration.should == 24 # default loan factory repayment duration is 2 years
          end

          it 'updates loan maturity date' do
            loan.reload
            loan.maturity_date.should == Date.new(2019, 4, 3)
            loan.modified_by.should == user
            loan.state.should == Loan::Guaranteed
          end

          it 'updates loan term' do
            loan.reload
            loan.initial_draw_change.date_of_change.should == Date.new(2015, 1, 31)
            loan.repayment_duration.total_months.should == 51
          end

          it 'creates state change record' do
            state_change = loan.state_changes.last!
            state_change.event_id.should == 9
            state_change.state.should == Loan::Guaranteed
          end

          it 'does not update Loan#business_name' do
            loan_change.old_business_name.should == nil
            loan.reload
            loan.business_name.should == 'ACME'
          end
        end
      end
    end

    context 'when not valid' do
      it 'does not update the Loan' do
        loan_change.save_and_update_loan.should == false
        loan.reload
        loan.business_name.should == 'ACME'
        loan.state.should == Loan::LenderDemand
      end

      it 'does not create a LoanStateChange' do
        expect {
          loan_change.save_and_update_loan.should == false
        }.to change(LoanStateChange, :count).by(0)
      end
    end

    context 'when state aid recalculation is required' do
      it 'creates new state aid calculation for the Loan' do
        loan_change.change_type_id = ChangeType::CapitalRepaymentHoliday.id

        loan_change.premium_schedule_attributes = FactoryGirl.attributes_for(
          :rescheduled_premium_schedule, loan: loan
        )

        expect {
          loan_change.save_and_update_loan
        }.to change(PremiumSchedule, :count).by(1)
      end

      it 'does not update the Loan if the state aid calculation is not valid' do
        loan_change.change_type_id = ChangeType::CapitalRepaymentHoliday.id
        loan_change.premium_schedule_attributes = {}
        loan_change.save_and_update_loan.should == false

        loan.reload
        loan.business_name.should == 'ACME'
        loan.state.should == Loan::LenderDemand
      end
    end
  end

  describe '#seq' do
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

    it 'is incremented for each change' do
      change1 = FactoryGirl.create(:loan_change, loan: loan)
      change2 = FactoryGirl.create(:loan_change, loan: loan)

      change1.seq.should == 1
      change2.seq.should == 2
    end
  end

  describe "state aid recalculation" do

    [
      ChangeType::CapitalRepaymentHoliday.id,
      ChangeType::ChangeRepayments.id,
      ChangeType::ExtendTerm.id,
      ChangeType::LumpSumRepayment.id,
      ChangeType::ReprofileDraws.id,
      ChangeType::DecreaseTerm.id,
    ].each do |change_type_id|
      it "should be required when change type ID is #{change_type_id}" do
        loan_change = FactoryGirl.build(:loan_change, change_type_id: change_type_id)
        loan_change.requires_state_aid_recalculation?.should be_true, "Expected true for change type ID #{change_type_id}"
      end
    end

    [ChangeType::BusinessName.id, ChangeType::RecordAgreedDraw.id].each do |change_type_id|
      it "should not be required when change type ID is #{change_type_id}" do
        loan_change = FactoryGirl.build(:loan_change, change_type_id: change_type_id)
        loan_change.requires_state_aid_recalculation?.should be_false, "Expected false for change type ID #{change_type_id}"
      end
    end

  end

end
