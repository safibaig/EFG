# encoding: utf-8

require 'spec_helper'

describe LoanChange do
  it_behaves_like 'LoanModification'

  describe 'validations' do
    let(:loan_change) { FactoryGirl.build(:loan_change) }

    it 'strictly requires a change_type_id' do
      expect {
        loan_change.change_type_id = ''
        loan_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'must have a valid change_type_id' do
      expect {
        loan_change.change_type_id = ChangeType::DataCorrection.id
        loan_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)

      expect {
        loan_change.change_type_id = 'zzz'
        loan_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'must not have a negative amount_drawn' do
      loan_change.amount_drawn = '-1'
      loan_change.should_not be_valid
    end

    it 'must not have a negative lump_sum_repayment' do
      loan_change.lump_sum_repayment = '-1'
      loan_change.should_not be_valid
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
end
