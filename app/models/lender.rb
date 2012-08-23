class Lender < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'
  belongs_to :modified_by, class_name: 'User'
  has_many :lender_admins
  has_many :lender_users
  has_many :loans
  has_many :loan_allocations

  attr_accessible :can_use_add_cap, :high_volume, :name,
    :organisation_reference_code, :primary_contact_email,
    :primary_contact_name, :primary_contact_phone

  validates_inclusion_of :can_use_add_cap, in: [true, false]
  validates_inclusion_of :high_volume, in: [true, false]
  validates_presence_of :name
  validates_presence_of :organisation_reference_code
  validates_presence_of :primary_contact_email
  validates_presence_of :primary_contact_name
  validates_presence_of :primary_contact_phone

  scope :order_by_name, order(:name)
end
