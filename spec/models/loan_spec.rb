require 'spec_helper'

describe Loan do
  let(:loan) { FactoryGirl.build(:loan) }

  describe 'validations' do
    it 'has a valid Factory' do
      loan.should be_valid
    end

    it 'strictly requires a lender' do
      expect {
        loan.lender = nil
        loan.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a state' do
      expect {
        loan.state = nil
        loan.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a known state' do
      expect {
        loan.state = 'not-a-known-state-yo'
        loan.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a creator' do
      expect {
        loan.created_by_id = nil
        loan.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a modifier' do
      expect {
        loan.modified_by_id = nil
        loan.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end

  describe ".last_updated_between scope" do
    let!(:loan1) { FactoryGirl.create(:loan, updated_at: 3.days.ago) }
    let!(:loan2) { FactoryGirl.create(:loan, updated_at: 1.day.ago) }

    it "returns loans last updated between the specified dates" do
      Loan.last_updated_between(2.days.ago, 1.day.ago).should == [loan2]
    end
  end

  describe ".not_progressed scope" do
    let!(:loan1) { FactoryGirl.create(:loan, :eligible) }
    let!(:loan2) { FactoryGirl.create(:loan, :completed) }
    let!(:loan3) { FactoryGirl.create(:loan, :incomplete) }
    let!(:loan4) { FactoryGirl.create(:loan, :offered) }

    it "returns loans with Eligible, Complete or Incomplete state" do
      result = Loan.not_progressed

      result.should include(loan1)
      result.should include(loan2)
      result.should include(loan3)
      result.should_not include(loan4)
    end
  end

  describe ".by_reference scope" do
    before(:each) do
      LoanReference.stub(:generate).and_return("ABC123", "ABC12345")
    end

    let!(:loan1) { FactoryGirl.create(:loan) }
    let!(:loan2) { FactoryGirl.create(:loan) }

    it "returns loans that partially or completely match the specified reference" do
      Loan.by_reference("ABC123").should == [loan1, loan2]
    end
  end

  describe '.with_scheme' do
    let!(:loan1) { FactoryGirl.create(:loan, :efg) }
    let!(:loan2) { FactoryGirl.create(:loan, :sflg) }
    let!(:loan3) { FactoryGirl.create(:loan, :legacy_sflg) }

    context 'efg' do
      it do
        Loan.with_scheme('efg').should == [loan1]
      end
    end

    context 'sflg' do
      it do
        Loan.with_scheme('sflg').should == [loan2]
      end
    end

    context 'legacy_sflg' do
      it do
        Loan.with_scheme('legacy_sflg').should == [loan3]
      end
    end

    context 'with an unknown scheme' do
      it do
        Loan.with_scheme('foo').should == []
      end
    end
  end

  describe "#state_aid_calculation" do

    let!(:loan) { FactoryGirl.create(:loan) }

    let!(:state_aid_calculation1) { FactoryGirl.create(:state_aid_calculation, loan: loan) }

    let!(:state_aid_calculation2) { FactoryGirl.create(:state_aid_calculation, loan: loan) }

    it "returns the most recent state aid calculation record" do
      loan.state_aid_calculation.should == state_aid_calculation2
    end
  end

  describe '#repayment_duration / #repayment_duration=' do
    let(:loan) { Loan.new }

    it 'conforms to the MonthDuration interface' do
      loan[:repayment_duration] = 18
      loan.repayment_duration.should == MonthDuration.new(18)
    end

    it 'converts year/months hash to months' do
      loan.repayment_duration = { years: 1, months: 6 }
      loan.repayment_duration.should == MonthDuration.new(18)
    end

    it 'does not convert blank values to zero' do
      loan.repayment_duration = { years: '', months: '' }
      loan.repayment_duration.should be_nil
    end
  end

  describe "#eligibility_check" do
    it "should instantiate and return an EligibiltyCheck" do
      loan = FactoryGirl.build(:loan)
      result = double(EligibilityCheck)
      EligibilityCheck.should_receive(:new).with(loan).and_return(result)

      loan.eligibility_check.should == result
    end
  end

  describe "#state_aid" do
    it "should return a EUR money object" do
      loan = FactoryGirl.build(:loan, state_aid: '100.00')
      loan.state_aid.should == Money.new(100_00, 'EUR')
    end

    it "return nil if not set" do
      loan = FactoryGirl.build(:loan, state_aid: '')
      loan.state_aid.should be_nil
    end
  end

  describe "#premium_schedule" do
    it "should return a PremiumSchedule for the loan" do
      loan = FactoryGirl.build(:loan)
      loan.state_aid_calculations.build

      loan.premium_schedule.should be_instance_of(PremiumSchedule)
      loan.premium_schedule.loan.should == loan
    end

    it "should return nil if it doesn't have a state aid calculation" do
      loan = FactoryGirl.build(:loan)
      loan.premium_schedule.should be_nil
    end
  end

  describe "reference" do
    let(:loan) {
      loan = FactoryGirl.build(:loan)
      loan.reference = nil
      loan
    }

    it "should be generated when loan is created" do
      loan.reference.should be_nil

      loan.save!

      loan.reference.should be_instance_of(String)
    end

    it "should be unique" do
      FactoryGirl.create(:loan, reference: 'ABC234')
      FactoryGirl.create(:loan, reference: 'DEF456')
      LoanReference.stub(:generate).and_return('ABC234', 'DEF456', 'GHF789')

      loan.save!

      loan.reference.should == 'GHF789'
    end

    it "should not be generated if already assigned" do
      loan.reference = "custom-reference"
      loan.save!
      loan.reload.reference.should == 'custom-reference'
    end
  end

  describe "#already_transferred" do
    it "returns true when a loan with the next incremented loan reference exists" do
      FactoryGirl.create(:loan, reference: 'Q9HTDF7-02')

      FactoryGirl.build(:loan, reference: 'Q9HTDF7-01').should be_already_transferred
    end

    it "returns false when loan with next incremented loan reference does not exist" do
      FactoryGirl.build(:loan, reference: 'Q9HTDF7-01').should_not be_already_transferred
    end

    it "returns false when loan has no reference" do
      Loan.new.should_not be_already_transferred
    end
  end

  describe "#created_from_transfer?" do
    it "returns true when a loan has been transferred from another loan" do
      loan = FactoryGirl.build(:loan, reference: 'Q9HTDF7-02')
      loan.should be_created_from_transfer
    end

    it "returns false when loan with next incremented loan reference does not exist" do
      loan = FactoryGirl.build(:loan, reference: 'Q9HTDF7-01')
      loan.should_not be_created_from_transfer
    end

    it "returns false when loan has no reference" do
      Loan.new.should_not be_created_from_transfer
    end
  end

  describe '#cumulative_drawn_amount' do
    before do
      loan.save!
    end

    it 'sums amount_drawn' do
      FactoryGirl.create(:initial_draw_change, loan: loan, amount_drawn: Money.new(123_45))
      FactoryGirl.create(:loan_change, loan: loan, amount_drawn: Money.new(678_90), change_type_id: '7')

      loan.cumulative_drawn_amount.should == Money.new(802_35)
    end
  end

  describe '#cumulative_realised_amount' do
    before do
      loan.save!
    end

    it 'sums all loan realisations' do
      FactoryGirl.create(:loan_realisation, realised_loan: loan, realised_amount: Money.new(123_45))
      FactoryGirl.create(:loan_realisation, realised_loan: loan, realised_amount: Money.new(678_90))

      loan.cumulative_realised_amount.should == Money.new(123_45) + Money.new(678_90)
    end
  end

  describe "#cumulative_unrealised_recoveries_amount" do
    let(:loan) { FactoryGirl.create(:loan, :settled, :recovered) }

    it 'sums all loan realisations' do
      FactoryGirl.create(:recovery, loan: loan, amount_due_to_dti: Money.new(500_00))
      FactoryGirl.create(:loan_realisation, realised_loan: loan, realised_amount: Money.new(200_00))

      loan.cumulative_unrealised_recoveries_amount.should == Money.new(300_00)
    end
  end

  describe "#last_realisation_amount" do
    before do
      loan.save!
    end

    it 'sums all loan realisations' do
      FactoryGirl.create(:loan_realisation, realised_loan: loan, realised_amount: Money.new(123_45))
      FactoryGirl.create(:loan_realisation, realised_loan: loan, realised_amount: Money.new(678_90))

      loan.last_realisation_amount.should == Money.new(678_90)
    end

    it "returns 0 money when loan has no realisations" do
      loan.last_realisation_amount.should == Money.new(0)
    end
  end

  describe '#amount_not_yet_drawn' do
    before do
      loan.save!
    end

    it 'returns loan amount minus cumulative amount drawn' do
      FactoryGirl.create(:initial_draw_change, loan: loan, amount_drawn: Money.new(123_45))
      FactoryGirl.create(:loan_change, loan: loan, amount_drawn: Money.new(678_90), change_type_id: '7')

      loan.amount_not_yet_drawn.should == loan.amount - Money.new(802_35)
    end
  end

  describe '#efg_loan?' do
    it "returns true when loan source is SFLG and loan type is EFG" do
      loan.loan_source = Loan::SFLG_SOURCE
      loan.loan_scheme = Loan::EFG_SCHEME

      loan.should be_efg_loan
    end

    it "returns false when loan source is not SFLG" do
      loan.loan_source = Loan::LEGACY_SFLG_SOURCE
      loan.loan_scheme = Loan::EFG_SCHEME

      loan.should_not be_efg_loan
    end

    it "returns false when loan source is SFLG but loan type is not EFG" do
      loan.loan_source = Loan::SFLG_SOURCE
      loan.loan_scheme = Loan::SFLG_SCHEME

      loan.should_not be_efg_loan
    end
  end

  describe '#legacy_loan?' do
    it "returns true when loan source is legacy SFLG" do
      loan.loan_source = Loan::LEGACY_SFLG_SOURCE

      loan.should be_legacy_loan
    end

    it "returns false when loan source is not legacy SFLG" do
      loan.loan_source = Loan::SFLG_SOURCE

      loan.should_not be_legacy_loan
    end
  end

  describe "#transferred_from" do
    let(:original_loan) { FactoryGirl.create(:loan, :repaid_from_transfer) }

    let(:transferred_loan) { FactoryGirl.create(:loan, transferred_from_id: original_loan.id) }

    it "returns the original loan from which this loan was transferred" do
      transferred_loan.transferred_from.should == original_loan
    end

    it "returns nil when loan is not a transfer" do
      Loan.new.transferred_from.should be_nil
    end
  end

  describe "#loan_security_types" do
    let(:security_type1) { LoanSecurityType.find(1) }

    let(:security_type2) { LoanSecurityType.find(5) }

    let!(:loan) { FactoryGirl.create(:loan) }

    it "should return all loan security types for a loan" do
      loan.loan_security_types = [ security_type1.id, security_type2.id ]
      loan.loan_security_types.should == [ security_type1, security_type2 ]
    end

    it "should ignore blank values when setting loan security types" do
      loan.loan_security_types = [ nil ]
      loan.loan_security_types.should be_empty
    end

    it "should remove existing loan securities" do
      loan.loan_security_types = [ security_type1.id ]
      loan.loan_security_types.should == [ security_type1 ]
      loan.loan_security_types = [ security_type2.id ]
      loan.loan_security_types.should == [ security_type2 ]
    end
  end

  describe "#guarantee_rate" do
    before do
      loan.guarantee_rate = 75
      loan.lending_limit.guarantee_rate = 85
    end

    it "returns the loan's guarantee rate when present" do
      loan.guarantee_rate.should == 75
    end

    it "falls back to the loan's LendingLimit guarantee rate" do
      loan.guarantee_rate = nil
      loan.guarantee_rate.should == 85
    end

    it "returns nil if the loan has no guarantee rate or lending limit" do
      loan.lending_limit = nil
      loan.guarantee_rate = nil
      loan.guarantee_rate.should be_nil
    end
  end

  describe "#premium_rate" do
    before do
      loan.premium_rate = 1.5
      loan.lending_limit.premium_rate = 2
    end

    it "returns the loan's premium rate when present" do
      loan.premium_rate.should == 1.5
    end

    it "falls back to the loan's LendingLimit premium rate" do
      loan.premium_rate = nil
      loan.premium_rate.should == 2
    end

    it "returns nil if the loan has no premium rate or lending limit" do
      loan.lending_limit = nil
      loan.premium_rate = nil
      loan.premium_rate.should be_nil
    end
  end

  describe "#state_history" do
    it "should return array of unique states a loan has or previously had" do
      loan.state = Loan::Demanded
      loan.save!

      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Eligible)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Completed)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Offered)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Guaranteed)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Guaranteed)

      loan.state_history.should == [
        Loan::Eligible,
        Loan::Completed,
        Loan::Offered,
        Loan::Guaranteed,
        Loan::Demanded
      ]
    end
  end

  describe "#update_status!" do
    let!(:system_user) { FactoryGirl.create(:system_user) }

    before(:each) do
      loan.save!
    end

    def dispatch
      loan.update_state!(Loan::AutoRemoved, LoanEvent::NotDrawn, system_user)
    end

    it "should change the state of the loan" do
      expect {
        dispatch
      }.to change(loan, :state).to(Loan::AutoRemoved)
    end

    it "should create loan state change record" do
      expect {
        dispatch
      }.to change(LoanStateChange, :count).by(1)

      state_change = loan.state_changes.last
      state_change.state.should == Loan::AutoRemoved
      state_change.modified_by.should == system_user
      state_change.event.should == LoanEvent::NotDrawn
    end
  end

  describe "#corrected?" do
    before(:each) do
      loan.save!
    end

    it "should be true when loan has had a data correction" do
      FactoryGirl.create(:data_correction, loan: loan)
      loan.should be_corrected
    end

    it "should be false when loan not had a data correction" do
      loan.should_not be_corrected
    end
  end

  describe "#calculate_dti_amount_claimed" do
    before { loan.calculate_dti_amount_claimed }

    context 'for EFG loan' do
      let(:loan) {
        FactoryGirl.build(
          :loan,
          :sflg,
          dti_demand_outstanding: Money.new(1_000_00),
          guarantee_rate: 75
        )
      }

      it "calculates dti_amount_claimed based on demand outstanding" do
        loan.dti_amount_claimed.should == Money.new(750_00)
      end
    end

    context 'for SFLG loan' do
      let(:loan) {
        FactoryGirl.build(
          :loan,
          :sflg,
          dti_demand_outstanding: Money.new(1_000_00),
          dti_interest: Money.new(500_00),
          dti_break_costs: Money.new(200_00),
          guarantee_rate: 75
        )
      }

      it "calculates dti_amount_claimed based on demand outstanding, interest and break costs" do
        loan.dti_amount_claimed.should == Money.new(1_275_00)
      end
    end

    context 'for legacy SFLG loan' do
      let(:loan) {
        FactoryGirl.build(
          :loan,
          :legacy_sflg,
          dti_demand_outstanding: Money.new(1_000_00),
          dti_interest: Money.new(500_00),
          dti_break_costs: Money.new(200_00),
          guarantee_rate: 75
        )
      }

      it "calculates dti_amount_claimed based on demand outstanding, interest and break costs" do
        loan.dti_amount_claimed.should == Money.new(1_275_00)
      end
    end

    context 'loan without demand outstanding, interest or break cost values' do
      let(:loan) { FactoryGirl.build(:loan, guarantee_rate: 75) }

      it "returns 0 when relevant values are not set on loan" do
        loan.dti_amount_claimed.should == Money.new(0)
      end
    end
  end

end
