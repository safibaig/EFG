require 'spec_helper'

describe AskAnExpert do
  describe 'validations' do
    let(:user) { FactoryGirl.build(:lender_user) }
    let(:ask_an_expert) { AskAnExpert.new(message: 'qwerty', user: user) }

    it 'requires a message' do
      ask_an_expert.message = ''
      ask_an_expert.should_not be_valid
    end

    it 'strictly requires a user' do
      expect {
        ask_an_expert.user = nil
        ask_an_expert.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
