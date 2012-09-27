require 'spec_helper'

describe Expert do
  describe 'validations' do
    let(:expert) { FactoryGirl.build(:expert) }

    it 'has a valid factory' do
      expert.should be_valid
    end

    it 'strictly requires a user' do
      expect {
        expert.user = nil
        expert.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
