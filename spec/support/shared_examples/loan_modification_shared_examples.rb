# encoding: utf-8

shared_examples_for 'LoanModification' do
  describe 'validations' do
    let(:loan_modification) { FactoryGirl.build(described_class.name.underscore) }

    it 'has a valid Factory' do
      loan_modification.should be_valid
    end

    it 'strictly requires a loan' do
      expect {
        loan_modification.loan = nil
        loan_modification.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a creator' do
      expect {
        loan_modification.created_by = nil
        loan_modification.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a date_of_change' do
      loan_modification.date_of_change = ''
      loan_modification.should_not be_valid
    end

    it 'strictly requires a modified_date' do
      expect {
        loan_modification.modified_date = ''
        loan_modification.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
