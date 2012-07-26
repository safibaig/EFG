require 'spec_helper'

describe LoanChange do
  describe 'validations' do
    let(:loan_change) { FactoryGirl.build(:loan_change) }

    it 'has a valid Factory' do
      loan_change.should be_valid
    end

    it 'requires a loan' do
      loan_change.loan = nil
      loan_change.should_not be_valid
    end

    it 'requires a creator' do
      loan_change.created_by = nil
      loan_change.should_not be_valid
    end

    %w(change_type_id date_of_change modified_date).each do |attr|
      it "requires #{attr}" do
        loan_change.send("#{attr}=", '')
        loan_change.should_not be_valid
      end
    end

    it 'must not have a negative amount_drawn' do
      loan_change.amount_drawn = '-1'
      loan_change.should_not be_valid
    end

    context 'change types' do
      context '1 - business name' do
        it 'requires a business_name' do
          loan_change.change_type_id = '1'
          loan_change.business_name = ''
          loan_change.should_not be_valid
          loan_change.business_name = 'ACME'
          loan_change.should be_valid
        end
      end

      context '5 - Lender demand satisfied' do
        before do
          loan_change.change_type_id = '5'
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

      context '7 - Record agreed draw' do
        it 'requires a amount_drawn' do
          loan_change.change_type_id = '7'
          loan_change.amount_drawn = ''
          loan_change.should_not be_valid
          loan_change.amount_drawn = '1,000'
          loan_change.should be_valid
        end
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
    let(:loan) { FactoryGirl.create(:loan, :lender_demand, business_name: 'ACME') }
    let(:loan_change) { FactoryGirl.build(:loan_change, loan: loan) }

    it 'works' do
      loan_change.business_name = 'updated'

      loan_change.save_and_update_loan.should == true
      loan.state.should == Loan::Guaranteed
      loan.business_name.should == 'updated'
    end

    it 'does not update the Loan if the LoanChange is not valid' do
      loan_change.business_name = ''
      loan_change.save_and_update_loan.should == false
      loan.business_name.should == 'ACME'
      loan.state.should == Loan::LenderDemand
    end
  end

  describe '#seq' do
    let(:loan) { FactoryGirl.create(:loan) }

    it 'is incremented for each change' do
      change0 = FactoryGirl.create(:loan_change, loan: loan)
      change1 = FactoryGirl.create(:loan_change, loan: loan)

      change0.seq.should == 0
      change1.seq.should == 1
    end
  end
end
