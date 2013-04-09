class Lender < ActiveRecord::Base

  EFG_SCHEME = 'E'

  belongs_to :created_by, class_name: 'User'
  belongs_to :modified_by, class_name: 'User'
  has_many :experts
  has_many :expert_users, through: :experts, source: :user
  has_many :lender_admins
  has_many :lending_limits
  has_many :active_lending_limits, class_name: 'LendingLimit', conditions: { active: true }
  has_many :lender_users
  has_many :loans
  has_many :users, class_name: 'User', conditions: { type: %w(LenderAdmin LenderUser) }

  attr_accessible :can_use_add_cap, :name,
    :organisation_reference_code, :primary_contact_email,
    :primary_contact_name, :primary_contact_phone, :loan_scheme

  validates_inclusion_of :can_use_add_cap, in: [true, false]
  validates_inclusion_of :loan_scheme, in: [ EFG_SCHEME ], allow_blank: true
  validates_presence_of :name
  validates_presence_of :organisation_reference_code
  validates_uniqueness_of :organisation_reference_code
  validates_presence_of :primary_contact_email
  validates_presence_of :primary_contact_name
  validates_presence_of :primary_contact_phone

  scope :order_by_name, order(:name)
  scope :active, -> { where(disabled: false) }

  def activate!
    self.disabled = false
    save(validate: false)
  end

  def active
    !disabled
  end

  def deactivate!
    self.disabled = true
    save(validate: false)
  end

  def current_lending_limits
    active_lending_limits.current
  end

  def current_annual_lending_limit_allocation
    current_lending_limit_allocation_for_type(LendingLimitType::Annual)
  end

  def current_specific_lending_limit_allocation
    current_lending_limit_allocation_for_type(LendingLimitType::Specific)
  end

  def can_access_all_loan_schemes?
    loan_scheme.blank?
  end

  def logo
    return nil if organisation_reference_code.blank?
    LenderLogo.new(organisation_reference_code)
  end

  private
    def current_lending_limit_allocation_for_type(type)
      current_lending_limits.where(allocation_type_id: type.id).sum(Money.new(0), &:allocation)
    end
end
