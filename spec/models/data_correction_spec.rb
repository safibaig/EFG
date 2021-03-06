# encoding: utf-8

require 'spec_helper'

describe DataCorrection do
  it_behaves_like 'LoanModification'

  describe 'validations' do
    let(:lender) { FactoryGirl.create(:lender) }
    let(:lending_limit) { FactoryGirl.create(:lending_limit, lender: lender, starts_on: Date.new(2011, 4), ends_on: Date.new(2012, 3, 31)) }
    let(:loan) { FactoryGirl.create(:loan, lender: lender, lending_limit: lending_limit, amount: Money.new(10_000_00), facility_letter_date: Date.new(2011, 8), dti_demand_outstanding: Money.new(1_000_00)) }
    let(:data_correction) { FactoryGirl.build(:data_correction, loan: loan) }
    let!(:initial_draw_change) { FactoryGirl.create(:initial_draw_change, loan: loan, amount_drawn: Money.new(5_000_00), date_of_change: Date.new(2011, 11)) }

    it 'must have something set' do
      data_correction.amount = ''
      data_correction.facility_letter_date = ''
      data_correction.initial_draw_date = ''
      data_correction.initial_draw_amount = ''
      data_correction.sortcode = ''
      data_correction.should_not be_valid
      data_correction.dti_demand_out_amount = ''
      data_correction.should_not be_valid
      data_correction.dti_demand_interest = ''
      data_correction.should_not be_valid
    end

    context '#amount' do
      it 'must not be the same as currently is' do
        data_correction.amount = data_correction.loan.amount
        data_correction.should_not be_valid
      end

      it 'must not be negative' do
        data_correction.amount = Money.new(-1)
        data_correction.should_not be_valid
      end

      it 'must be between £1,000 and £1,000,000' do
        data_correction.amount = '999.99'
        data_correction.should_not be_valid
        data_correction.amount = '1000000.01'
        data_correction.should_not be_valid
        data_correction.amount = '999999.99'
        data_correction.should be_valid
      end

      it 'must be >= total cumulative amount drawn' do
        FactoryGirl.create(:loan_change, loan: loan, amount_drawn: Money.new(1_000_00))

        data_correction.amount = Money.new(5_999_99)
        data_correction.should_not be_valid
      end

      it 'must be >= total cumulative amount drawn (including changes to initial_draw_amount)' do
        FactoryGirl.create(:loan_change, loan: loan, amount_drawn: Money.new(1_000_00))

        data_correction.amount = Money.new(6_999_99)
        data_correction.initial_draw_amount = Money.new(6_000_00)
        data_correction.should_not be_valid
      end

      context 'for SFLG loans' do
        before do
          loan.loan_source = Loan::SFLG_SOURCE
          loan.loan_scheme = Loan::SFLG_SCHEME
          loan.save!
        end

        it 'must be between £5,000 and £250,000' do
          data_correction.amount = '4999.99'
          data_correction.should_not be_valid
          data_correction.amount = '250000.01'
          data_correction.should_not be_valid
          data_correction.amount = '249999.99'
          data_correction.should be_valid
        end
      end
    end

    context '#facility_letter_date' do
      it 'must not be in the future' do
        data_correction.facility_letter_date = Date.current.advance(days: 1)
        data_correction.should_not be_valid
      end

      it 'must be no more than 6 months before the initial draw date' do
        data_correction.facility_letter_date = Date.new(2011, 4, 30)
        data_correction.should_not be_valid
        data_correction.facility_letter_date = Date.new(2011, 5)
        data_correction.should be_valid
      end

      it 'must be no more than 6 months before the initial draw date (including change to the initial_draw_date)' do
        data_correction.facility_letter_date = Date.new(2011, 5, 31)
        data_correction.initial_draw_date = Date.new(2011, 12, 1)
        data_correction.should_not be_valid
        data_correction.facility_letter_date = Date.new(2011, 6)
        data_correction.should be_valid
      end

      it 'must be between the lending limit start/end dates' do
        data_correction.facility_letter_date = Date.new(2011, 3, 31)
        data_correction.initial_draw_date = Date.new(2011, 7)
        data_correction.should_not be_valid
        data_correction.facility_letter_date = Date.new(2011, 4)
        data_correction.should be_valid
      end
    end

    context '#initial_draw_amount' do
      it 'must not take the cumulative amount drawn over the loan amount' do
        FactoryGirl.create(:loan_change, loan: loan, amount_drawn: Money.new(5_000_00))

        data_correction.initial_draw_amount = Money.new(5_000_01)
        data_correction.should_not be_valid
        data_correction.initial_draw_amount = Money.new(5_000_00)
        data_correction.should be_valid
      end

      it 'must not take the cumulative amount drawn over the loan amount (including change to amount)' do
        FactoryGirl.create(:loan_change, loan: loan, amount_drawn: Money.new(5_000_00))

        data_correction.amount = Money.new(11_000_00)
        data_correction.initial_draw_amount = Money.new(6_000_01)
        data_correction.should_not be_valid
        data_correction.initial_draw_amount = Money.new(6_000_00)
        data_correction.should be_valid
      end
    end

    context '#initial_draw_date' do
      it 'must not be in the future' do
        data_correction.initial_draw_date = Date.current.advance(days: 1)
        data_correction.should_not be_valid
      end

      it "must not be before the loan's facility letter date" do
        data_correction.initial_draw_date = Date.new(2011, 7, 31)
        data_correction.should_not be_valid
      end

      it "must not be more than six months after the loan's facility letter date" do
        data_correction.initial_draw_date = Date.new(2012, 2, 2)
        data_correction.should_not be_valid
        data_correction.initial_draw_date = Date.new(2012, 2, 1)
        data_correction.should be_valid
      end

      it "must not be more than six months after the loan's facility letter date (including change to facility letter date)" do
        data_correction.facility_letter_date = Date.new(2011, 9)
        data_correction.initial_draw_date = Date.new(2012, 3, 2)
        data_correction.should_not be_valid
        data_correction.initial_draw_date = Date.new(2012, 3, 1)
        data_correction.should be_valid
      end
    end

    describe '#dti_demand_out_amount=' do
      it 'is not be valid when loan is not in demanded state' do
        loan.state.should_not == Loan::Demanded
        data_correction.dti_demand_out_amount = Money.new(800_00)
        data_correction.should_not be_valid
      end

      context 'when loan is in demanded state' do
        before do
          loan.update_attribute(:state, Loan::Demanded)
        end

        it 'must not be negative' do
          data_correction.dti_demand_out_amount = Money.new(-1)
          data_correction.should_not be_valid
        end

        it 'must not be the same value' do
          data_correction.dti_demand_out_amount = loan.dti_demand_outstanding
          data_correction.should_not be_valid
        end

        it 'must not be greater than the total amount drawn' do
          data_correction.dti_demand_out_amount = loan.cumulative_drawn_amount + Money.new(1_00)
          data_correction.should_not be_valid
        end
      end
    end

    describe '#dti_demand_interest=' do
      it 'is not be valid when loan is not in demanded state' do
        loan.state.should_not == Loan::Demanded
        data_correction.dti_demand_interest = Money.new(800_00)
        data_correction.should_not be_valid
      end

      context 'when loan is in demanded state' do
        before do
          loan.state = Loan::Demanded
          loan.loan_scheme = Loan::SFLG_SCHEME
          loan.dti_interest = Money.new(1_000_00)
          loan.save!
        end

        it 'is not valid when an EFG loan' do
          loan.update_attribute(:loan_scheme, Loan::EFG_SCHEME)

          data_correction.dti_demand_interest = Money.new(800_00)
          data_correction.should_not be_valid
        end

        it 'must not be negative' do
          data_correction.dti_demand_interest = Money.new(-1)
          data_correction.should_not be_valid
        end

        it 'must not be the same value' do
          data_correction.dti_demand_interest = loan.dti_interest
          data_correction.should_not be_valid
        end

        it 'must be lte to original loan amount when amount is not being changed' do
          data_correction.dti_demand_interest = loan.amount + Money.new(1_00)
          data_correction.should_not be_valid
        end

        it 'must be lte to new loan amount when amount is being changed' do
          data_correction.amount = Money.new(5_000_00)
          data_correction.dti_demand_interest = Money.new(5_001_00)
          data_correction.should_not be_valid
        end
      end
    end
  end

  describe '#save_and_update_loan' do
    let(:lender) { FactoryGirl.create(:lender) }
    let(:user) { FactoryGirl.create(:lender_user, lender: lender) }
    let(:lending_limit) { FactoryGirl.create(:lending_limit, lender: lender, starts_on: Date.new(2012)) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: lender, lending_limit: lending_limit, amount: Money.new(5_000_00), facility_letter_date: Date.new(2012, 1, 1), sortcode: '123456', dti_demand_outstanding: Money.new(1_000_00)) }
    let!(:initial_draw_change) {
      loan.initial_draw_change.tap { |initial_draw_change|
        initial_draw_change.amount_drawn = Money.new(1_000_00)
        initial_draw_change.date_of_change = Date.new(2012, 3, 4)
        initial_draw_change.save!
      }
    }
    let(:data_correction) {
      DataCorrection.new do |data_correction|
        data_correction.created_by = user
        data_correction.date_of_change = Date.current
        data_correction.loan = loan
        data_correction.modified_date = Date.current
      end
    }

    it 'works with #amount' do
      data_correction.amount = Money.new(6_000_00)
      data_correction.save_and_update_loan.should == true
      data_correction.old_amount.should == Money.new(5_000_00)

      loan.reload
      loan.amount.should == Money.new(6_000_00)
    end

    it 'works with #facility_letter_date' do
      data_correction.facility_letter_date = Date.new(2012, 2, 2)
      data_correction.save_and_update_loan.should == true
      data_correction.old_facility_letter_date.should == Date.new(2012, 1, 1)

      loan.reload
      loan.facility_letter_date.should == Date.new(2012, 2, 2)
    end

    it 'works with #initial_draw_amount' do
      data_correction.initial_draw_amount = Money.new(2_000_00)
      data_correction.save_and_update_loan.should == true
      data_correction.old_initial_draw_amount.should == Money.new(1_000_00)

      initial_draw_change.reload
      initial_draw_change.amount_drawn.should == Money.new(2_000_00)
    end

    it 'works with #initial_draw_date' do
      data_correction.initial_draw_date = Date.new(2012, 4, 3)
      data_correction.save_and_update_loan.should == true
      data_correction.old_initial_draw_date = Date.new(2012, 3, 4)

      initial_draw_change.reload
      initial_draw_change.date_of_change.should == Date.new(2012, 4, 3)
    end

    it 'works with #sortcode' do
      data_correction.sortcode = '654321'
      data_correction.save_and_update_loan.should == true
      data_correction.old_sortcode.should == '123456'

      loan.reload
      loan.sortcode.should == '654321'
    end

    context 'with demanded loan' do
      before do
        loan.update_attribute(:state, Loan::Demanded)
      end

      it 'works with #dti_demand_out_amount' do
        data_correction.dti_demand_out_amount = Money.new(800_00)
        data_correction.save_and_update_loan.should == true
        data_correction.old_dti_demand_out_amount.should == Money.new(1_000_00)

        loan.reload
        loan.dti_demand_outstanding.should == Money.new(800_00)
      end

      it 'recalculates #dti_amount_claimed when updating #dti_demand_out_amount' do
        data_correction.dti_demand_out_amount = Money.new(800_00)
        data_correction.save_and_update_loan.should == true

        loan.reload
        loan.dti_amount_claimed.should == Money.new(600_00) # 75% of £800 (#dti_demand_outstanding)
      end

      context 'in SFLG scheme' do
        before do
          loan.loan_scheme = Loan::SFLG_SCHEME
          loan.save!
        end

        it 'works with #dti_demand_interest' do
          loan.update_attribute(:dti_interest, Money.new(1_000_00))

          data_correction.dti_demand_interest = Money.new(800_00)
          data_correction.save_and_update_loan.should == true
          data_correction.old_dti_demand_interest.should == Money.new(1_000_00)

          loan.reload
          loan.dti_interest.should == Money.new(800_00)
        end

        it 'recalculates #dti_amount_claimed when updating #dti_demand_interest' do
          data_correction.dti_demand_interest = Money.new(500_00)
          data_correction.save_and_update_loan.should == true

          loan.reload
          loan.dti_amount_claimed.should == Money.new(1125_00) # 75% of £1500 (#dti_demand_outstanding + #dti_interest)
        end
      end

      context 'in Legacy SFLG scheme' do
        before do
          loan.loan_scheme = Loan::SFLG_SCHEME
          loan.loan_source = Loan::LEGACY_SFLG_SOURCE
          loan.save!
        end

        it 'works with #dti_demand_interest' do
          loan.update_attribute(:dti_interest, Money.new(1_000_00))

          data_correction.dti_demand_interest = Money.new(800_00)
          data_correction.save_and_update_loan.should == true
          data_correction.old_dti_demand_interest.should == Money.new(1_000_00)

          loan.reload
          loan.dti_interest.should == Money.new(800_00)
        end

        it 'recalculates #dti_amount_claimed when updating #dti_demand_interest' do
          data_correction.dti_demand_interest = Money.new(500_00)
          data_correction.save_and_update_loan.should == true

          loan.reload
          loan.dti_amount_claimed.should == Money.new(1125_00) # 75% of £1500 (#dti_demand_outstanding + #dti_interest)
        end
      end
    end

    it 'creates a new loan state change record for the state change' do
      expect {
        data_correction.amount = Money.new(6_000_00)
        data_correction.save_and_update_loan
      }.to change(LoanStateChange, :count).by(1)

      state_change = loan.state_changes.last
      state_change.event_id.should == 22
      state_change.state.should == Loan::Guaranteed
    end
  end

  describe '#seq' do
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

    it 'is incremented for each DataCorrection' do
      correction1 = FactoryGirl.create(:data_correction, loan: loan)
      correction2 = FactoryGirl.create(:data_correction, loan: loan)

      correction1.seq.should == 1
      correction2.seq.should == 2
    end
  end

  describe "#changes" do
    describe "data correction with lending limit change" do
      it "should return the old and new lending limits" do
        lender = FactoryGirl.create(:lender)
        lending_limit_1 = FactoryGirl.create(:lending_limit, lender: lender)
        lending_limit_2 = FactoryGirl.create(:lending_limit, lender: lender)

        data_correction = FactoryGirl.create(:data_correction, old_lending_limit_id: lending_limit_1.id, lending_limit_id: lending_limit_2.id)
        data_correction.changes.should == [{
          old_attribute: 'old_lending_limit',
          old_value: lending_limit_1,
          attribute: 'lending_limit',
          value: lending_limit_2
        }]
      end
    end
  end
end
