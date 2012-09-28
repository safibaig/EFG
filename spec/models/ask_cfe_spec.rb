require 'spec_helper'

describe AskCfe do
  describe 'validations' do
    let(:user) { FactoryGirl.build(:auditor_user) }
    let(:ask_cfe) { AskCfe.new(message: 'qwerty', user: user) }

    it 'requires a message' do
      ask_cfe.message = ''
      ask_cfe.should_not be_valid
    end

    it 'strictly requires a user' do
      expect {
        ask_cfe.user = nil
        ask_cfe.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
