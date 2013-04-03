require 'spec_helper'

describe DemandedAmountDataCorrection do
  describe 'validations' do
    let(:presenter) { FactoryGirl.build(:demanded_amount_data_correction) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, :demanded, dti_demand_outstanding: Money.new(1_000_00), dti_interest: Money.new(100_00)) }

    it 'has a valid factory' do
      presenter.should be_valid
    end

    it 'strictly requires the loan to be Demanded' do
      expect {
        presenter.loan.state = Loan::Guaranteed
        presenter.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a change' do
      presenter.demanded_amount = ''
      presenter.demanded_interest = ''
      presenter.should_not be_valid
    end

    context '#demanded_amount=' do
      before do
        presenter.loan = loan
      end

      it 'must not be negative' do
        presenter.demanded_amount = Money.new(-1)
        presenter.should_not be_valid
      end

      it 'must not be the same value' do
        presenter.demanded_amount = loan.dti_demand_outstanding
        presenter.should_not be_valid
      end

      it 'must not be greater than the cumulative_drawn_amount' do
        presenter.demanded_amount = loan.cumulative_drawn_amount + Money.new(1)
        presenter.should_not be_valid
      end
    end

    context '#demanded_interest=' do
      before do
        presenter.loan = loan
      end

      it 'must not be negative' do
        presenter.demanded_interest = Money.new(-1)
        presenter.should_not be_valid
      end

      it 'must not be the same value' do
        presenter.demanded_interest = loan.dti_interest
        presenter.should_not be_valid
      end

      it 'must be lte to original loan amount when amount is not being changed' do
        presenter.demanded_interest = loan.amount + Money.new(1)
        presenter.should_not be_valid
      end
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:presenter) { FactoryGirl.build(:demanded_amount_data_correction, created_by: user, loan: loan) }

    context 'EFG loan' do
      let(:loan) { FactoryGirl.create(:loan, :guaranteed, :demanded, dti_demand_outstanding: Money.new(1_000_00), dti_interest: nil) }

      context 'success' do
        it 'creates a DataCorrection and updates the loan' do
          presenter.demanded_amount = '1,234.56'
          presenter.demanded_interest = '123.45' # ignored
          presenter.save.should == true

          data_correction = loan.data_corrections.last!
          data_correction.created_by.should == user
          data_correction.dti_demand_out_amount.should == Money.new(1_234_56)
          data_correction.old_dti_demand_out_amount.should == Money.new(1_000_00)
          data_correction.dti_demand_interest.should be_nil
          data_correction.old_dti_demand_interest.should be_nil

          loan.reload
          loan.dti_demand_outstanding.should == Money.new(1_234_56)
          loan.dti_interest.should be_nil
          loan.last_modified_at.should_not == 1.year.ago
          loan.modified_by.should == user
        end
      end

      context 'failure' do
        it 'does not update the loan' do
          presenter.demanded_amount = ''
          presenter.save.should == false

          loan.reload
          loan.dti_demand_outstanding.should == Money.new(1_000_00)
        end
      end
    end

    context 'non-EFG loan' do
      let(:loan) { FactoryGirl.create(:loan, :sflg, :guaranteed, :demanded, dti_demand_outstanding: Money.new(1_000_00), dti_interest: Money.new(100_00)) }

      context 'success' do
        it 'also updates demand_interest' do
          presenter.demanded_amount = '1,234.56'
          presenter.demanded_interest = '123.45'
          presenter.save.should == true

          data_correction = loan.data_corrections.last!
          data_correction.dti_demand_out_amount.should == Money.new(1_234_56)
          data_correction.old_dti_demand_out_amount.should == Money.new(1_000_00)
          data_correction.dti_demand_interest.should == Money.new(123_45)
          data_correction.old_dti_demand_interest.should == Money.new(100_00)

          loan.reload
          loan.dti_demand_outstanding.should == Money.new(1_234_56)
          loan.dti_interest.should == Money.new(123_45)
        end

        it 'can update values to zero' do
          presenter.demanded_amount = '0'
          presenter.demanded_interest = '0'
          presenter.save.should == true

          loan.reload
          loan.dti_demand_outstanding.should == Money.new(0)
          loan.dti_interest.should == Money.new(0)
        end
      end

      context 'failure' do
        it 'does not update the loan' do
          presenter.demanded_amount = ''
          presenter.demanded_interest = ''
          presenter.save.should == false

          loan.reload
          loan.dti_demand_outstanding.should == Money.new(1_000_00)
          loan.dti_interest.should == Money.new(100_00)
        end
      end
    end
  end
end
