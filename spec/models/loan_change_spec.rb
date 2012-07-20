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
