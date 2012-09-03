class Lender < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'
  belongs_to :modified_by, class_name: 'User'
  has_many :lender_admins
  has_many :lending_limits
  has_many :active_lending_limits, class_name: 'LendingLimit', conditions: { active: true }
  has_many :lender_users
  has_many :loans

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

  def current_annual_lending_limit_allocation
    current_lending_limit_allocation_for_type(1)
  end

  def current_lending_limits
    today = Date.current

    active_lending_limits.select { |lending_limit|
      today.between?(lending_limit.starts_on, lending_limit.ends_on)
    }
  end

  def current_specific_lending_limit_allocation
    current_lending_limit_allocation_for_type(2)
  end

  private
    def current_lending_limit_allocation_for_type(type_id)
      current_lending_limits.select { |lending_limit|
        lending_limit.allocation_type_id == type_id
      }.inject(Money.new(0)) { |memo, lending_limit|
        memo += lending_limit.allocation
      }
    end
end
