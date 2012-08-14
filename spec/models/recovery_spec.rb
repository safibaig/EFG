require 'spec_helper'

describe Recovery do
  describe 'validations' do
    let(:recovery) { FactoryGirl.build(:recovery) }

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
    it 'behaves like the Visio document example' do
      recovery = FactoryGirl.build(:recovery,
        outstanding_non_efg_debt: Money.new(2_000_00),
        non_linked_security_proceeds: Money.new(3_000_00),
        linked_security_proceeds: Money.new(1_000_00)
      )
      recovery.calculate
      recovery.realisations_attributable.should == Money.new(2_000_00)
      recovery.amount_due_to_dti.should == Money.new(1_500_00)
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
