require 'spec_helper'

describe Recovery do
  let(:recovery) { FactoryGirl.build(:recovery) }

  describe 'validations' do
    it 'has a valid Factory' do
      recovery.should be_valid
    end

    it 'requires a loan' do
      recovery.loan = nil
      recovery.should_not be_valid
    end

    it 'requires a creator' do
      recovery.created_by = nil
      recovery.should_not be_valid
    end

    it 'recovered_on must be after its loan was settled' do
      recovery.loan.settled_on = Date.today
      recovery.recovered_on = 1.day.ago
      recovery.should_not be_valid
    end

    %w(
      recovered_on
      outstanding_non_efg_debt
      non_linked_security_proceeds
      linked_security_proceeds
    ).each do |attr|
      it "requires #{attr}" do
        recovery.send("#{attr}=", '')
        recovery.should_not be_valid
      end
    end
  end

  describe '#calculate' do
    let(:recovery) {
      Recovery.new.tap { |recovery|
        recovery.loan = loan
      }
    }

    context 'EFG' do
      let(:loan) {
        FactoryGirl.build(:loan, :settled,
          amount: Money.new(50_000_00),
          dti_demand_outstanding: Money.new(25_000_00),
          dti_amount_claimed: Money.new(18_750_00),
        )
      }

      it 'behaves like the Visio document P34 example' do
        recovery.outstanding_non_efg_debt = Money.new(2_000_00)
        recovery.non_linked_security_proceeds = Money.new(3_000_00)
        recovery.linked_security_proceeds = Money.new(1_000_00)
        recovery.calculate

        recovery.realisations_attributable.should == Money.new(2_000_00)
        recovery.amount_due_to_dti.should == Money.new(1_500_00)
      end

      it 'works' do
        recovery.outstanding_non_efg_debt = Money.new(1_234_00)
        recovery.non_linked_security_proceeds = Money.new(4_321_00)
        recovery.linked_security_proceeds = Money.new(5_678_00)
        recovery.calculate

        recovery.realisations_attributable.should == Money.new(8_765_00)
        recovery.amount_due_to_dti.should == Money.new(6_573_75)
      end

      it 'ensures positive values' do
        recovery.outstanding_non_efg_debt = Money.new(2_000_00)
        recovery.non_linked_security_proceeds = Money.new(1_000_00)
        recovery.linked_security_proceeds = Money.new(0)
        recovery.calculate

        recovery.realisations_attributable.should == Money.new(0)
        recovery.amount_due_to_dti.should == Money.new(0)
      end

      it 'ensures excess money is not paid back to the government' do
        recovery.outstanding_non_efg_debt = Money.new(12_340_00)
        recovery.non_linked_security_proceeds = Money.new(43_210_00)
        recovery.linked_security_proceeds = Money.new(56_780_00)
        recovery.calculate

        recovery.realisations_attributable.should == Money.new(87_650_00)
        recovery.amount_due_to_dti.should == Money.new(18_750_00)
      end
    end
  end

  describe '#save_and_update_loan' do
    context 'when the recovery is valid' do
      let(:user) { FactoryGirl.create(:lender_user) }
      let(:recovery) { FactoryGirl.build(:recovery, created_by: user) }
      let(:loan) { recovery.loan }

      it 'saves the recovery' do
        expect {
          recovery.save_and_update_loan
        }.to change(Recovery, :count).by(1)
      end

      it 'updates the loan state to recovered' do
        recovery.save_and_update_loan
        loan.reload.state.should == Loan::Recovered
      end

      it 'stores who last modified the loan' do
        recovery.save_and_update_loan
        loan.reload.modified_by == user
      end

      it 'stores the recovered date on the loan' do
        recovery.save_and_update_loan
        loan.reload.recovery_on.should == recovery.recovered_on
      end

      it 'creates a new loan state change record for the state change' do
        expect {
          recovery.save_and_update_loan
        }.to change(LoanStateChange, :count).by(1)

        state_change = loan.state_changes.last
        state_change.event_id.should == 20
        state_change.state.should == Loan::Recovered
      end
    end

    context 'when the recovery is not valid' do
      let(:loan) { FactoryGirl.create(:loan) }
      let(:recovery) { loan.recoveries.new }

      it 'returns false' do
        recovery.save_and_update_loan.should == false
      end
    end
  end
end
