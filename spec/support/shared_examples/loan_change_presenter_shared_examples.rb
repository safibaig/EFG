shared_examples_for 'LoanChangePresenter' do
  describe 'validations' do
    let(:factory_name) { described_class.name.tableize.singularize }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }
    let(:presenter) { FactoryGirl.build(factory_name, loan: loan) }

    it 'requires a date_of_change' do
      presenter.date_of_change = nil
      presenter.should_not be_valid
    end

    it 'strictly requires a created_by' do
      expect {
        presenter.created_by = nil
        presenter.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
