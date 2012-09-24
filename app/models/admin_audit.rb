class AdminAudit < ActiveRecord::Base
  LenderCreated = 'Lender created'
  LenderDisabled = 'Lender disabled'
  LenderEdited = 'Lender edited'
  LenderEnabled = 'Lender enabled'
  LendingLimitCreated = 'Add Lender Lending limit'
  LendingLimitEdited = 'Edit Lending limit'
  LendingLimitRemoved = 'Remove Lender Lending limit'
  UserCreated = 'User created'
  UserDisabled = 'User disabled'
  UserEdited = 'User edited'
  UserEnabled = 'User enabled'
  UserInitialLogin = 'Initial login'
  UserPasswordChanged = 'User password changed'
  UserUnlocked = 'User unlocked'

  belongs_to :auditable, polymorphic: true
  belongs_to :modified_by, class_name: 'User'

  validates_presence_of :action, strict: true
  validates_presence_of :auditable, strict: true
  validates_presence_of :modified_by, strict: true
  validates_presence_of :modified_on, strict: true

  def self.log(action, auditable, modifier)
    create! do |admin_audit|
      admin_audit.action = action
      admin_audit.auditable = auditable
      admin_audit.modified_by = modifier
      admin_audit.modified_on = Date.current
    end
  end
end
