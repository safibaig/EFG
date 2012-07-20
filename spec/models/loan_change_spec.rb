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

    %w(change_type_id date_of_change modified_date seq).each do |attr|
      it "requires #{attr}" do
        loan_change.send("#{attr}=", '')
        loan_change.should_not be_valid
      end
    end
  end
end
