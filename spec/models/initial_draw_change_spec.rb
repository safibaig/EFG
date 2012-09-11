require 'spec_helper'

describe InitialDrawChange do
  it_behaves_like 'LoanModification'

  describe 'validations' do
    let(:initial_draw_change) { FactoryGirl.build(:initial_draw_change) }

    it 'strictly requires #amount_drawn' do
      expect {
        initial_draw_change.amount_drawn = ''
        initial_draw_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
