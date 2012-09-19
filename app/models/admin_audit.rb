class AdminAudit < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true
  belongs_to :modified_by, class_name: 'User'

  validates_presence_of :action, strict: true
  validates_presence_of :auditable, strict: true
  validates_presence_of :modified_by, strict: true
  validates_presence_of :modified_on, strict: true
end
