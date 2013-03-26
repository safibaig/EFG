class LendingLimit < ActiveRecord::Base
  include FormatterConcern

  USAGE_LOAN_STATES = [
    Loan::Guaranteed,
    Loan::LenderDemand,
    Loan::Repaid,
    Loan::Removed,
    Loan::RepaidFromTransfer,
    Loan::AutoRemoved,
    Loan::NotDemanded,
    Loan::Demanded,
    Loan::Settled,
    Loan::Realised,
    Loan::Recovered
  ]

  belongs_to :lender
  belongs_to :modified_by, class_name: 'User'
  belongs_to :phase

  has_many :loans

  has_many :loans_using_lending_limit,
           class_name: "Loan",
           conditions: ["loans.state IN (?)", USAGE_LOAN_STATES]

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation, :name, :ends_on, :guarantee_rate,
    :premium_rate, :starts_on
  validates_inclusion_of :allocation_type_id, in: [LendingLimitType::Annual, LendingLimitType::Specific].map(&:id)
  validate :ends_on_is_after_starts_on

  attr_accessible :allocation, :allocation_type_id, :name, :ends_on,
    :guarantee_rate, :premium_rate, :starts_on, :phase_id

  format :allocation, with: MoneyFormatter.new
  format :ends_on, with: QuickDateFormatter
  format :starts_on, with: QuickDateFormatter

  default_scope order('ends_on DESC, allocation_type_id DESC')

  scope :active, where(active: true)

  def self.current
    today = Date.current

    scoped.where("starts_on <= ? AND ends_on >= ?", today, today)
  end

  def allocation_type
    LendingLimitType.find(allocation_type_id)
  end

  def activate!
    update_attribute(:active, true)
  end

  def deactivate!
    update_attribute(:active, false)
  end

  def available?
    active && (starts_on..ends_on).cover?(Date.today)
  end

  def unavailable?
    !available?
  end

  private
    def ends_on_is_after_starts_on
      return if ends_on.nil? || starts_on.nil?
      errors.add(:ends_on, :must_be_after_starts_on) if ends_on < starts_on
    end
end
