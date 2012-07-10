require 'spec_helper'

describe RecoveryPresenter do
  let(:loan) { FactoryGirl.create(:loan, :settled) }
  let(:recovery_presenter) { RecoveryPresenter.new(loan) }

  describe '#initialize' do
    it 'works when the loan is recovered' do
      loan.state = Loan::Recovered

      expect {
        recovery_presenter
      }.not_to raise_error(RecoveryPresenter::IncorrectLoanState)
    end

    it 'raises an IncorrectLoanState error if the loan is not settled/recovered' do
      loan.state = Loan::Eligible

      expect {
        recovery_presenter
      }.to raise_error(RecoveryPresenter::IncorrectLoanState)
    end
  end

  describe '#attributes=' do
    let(:recovery) { recovery_presenter.recovery }

    it 'forwards attributes to the recovery' do
      recovery.should_receive(:recovered_on=).with('12/12/12')

      recovery_presenter.attributes = { 'recovered_on' => '12/12/12' }
    end

    it 'does not forward undefined attributes' do
      recovery.should_not_receive(:junk=)

      recovery_presenter.attributes = { 'junk' => 'junk' }
    end
  end

  describe '#save' do
    context 'when the recovery is valid' do
      let(:recovery) { recovery_presenter.recovery }
      let(:created_by) { FactoryGirl.create(:lender_user) }

      before do
        recovery_presenter.attributes = FactoryGirl.attributes_for(:recovery,
          recovered_on: Date.new(2012, 6, 1)
        )
        recovery_presenter.created_by = created_by
      end

      it 'creates a Recovery' do
        expect {
          recovery_presenter.save
        }.to change(Recovery, :count).by(1)
      end

      it 'stores the user on the Recovery' do
        recovery_presenter.save
        recovery_presenter.recovery.created_by.should == created_by
      end

      it 'stores the recovered date on the loan' do
        recovery_presenter.save
        loan.reload.recovery_on.should == Date.new(2012, 6, 1)
      end

      context 'and the loan.state is settled' do
        it 'changes the state to recovered' do
          recovery_presenter.save
          recovery_presenter.loan.reload.state.should == Loan::Recovered
        end
      end

      context 'and the loan.state is recovered' do
        it 'keeps the state as recovered' do
          recovery_presenter.save
          recovery_presenter.loan.reload.state.should == Loan::Recovered
        end
      end
    end

    context 'when the recovery is not valid' do
      it 'returns false' do
        recovery_presenter.save.should == false
      end

      it 'does not create a Recovery' do
        expect {
          recovery_presenter.save
        }.not_to change(Recovery, :count)
      end

      it 'does not change the loan.state' do
        expect {
          recovery_presenter.save
          loan.reload
        }.not_to change(loan, :state)
      end
    end
  end
end
