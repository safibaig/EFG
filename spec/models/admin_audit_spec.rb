require 'spec_helper'

describe AdminAudit do
  describe 'validations' do
    let(:admin_audit) { FactoryGirl.build(:admin_audit) }

    it 'has a valid factory' do
      admin_audit.should be_valid
    end

    it 'strictly requires action' do
      expect {
        admin_audit.action = ''
        admin_audit.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires auditable' do
      expect {
        admin_audit.auditable = nil
        admin_audit.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires modified_by_id' do
      expect {
        admin_audit.modified_by_id = ''
        admin_audit.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires modified_on' do
      expect {
        admin_audit.modified_on = ''
        admin_audit.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
