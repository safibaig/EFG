class LendingLimit < ActiveRecord::Base
  include FormatterConcern

  # TODO: verify these are the correct states
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

  has_many :loans

  has_many :loans_using_allocation,
           class_name: "Loan",
           conditions: ["loans.state IN (?)", USAGE_LOAN_STATES]

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation, :name, :ends_on, :guarantee_rate,
    :premium_rate, :starts_on
  validates_inclusion_of :allocation_type_id, in: [1, 2]
  validate :ends_on_is_after_starts_on

  attr_accessible :allocation, :allocation_type_id, :name, :ends_on,
    :guarantee_rate, :premium_rate, :starts_on

  format :allocation, with: MoneyFormatter.new
  format :ends_on, with: QuickDateFormatter
  format :starts_on, with: QuickDateFormatter

  default_scope order('ends_on DESC, allocation_type_id DESC')

  def allocation_type
    LendingLimitType.find(allocation_type_id)
  end

  def deactivate!
    self.active = false
    save(validate: false)
  end

  def title
    start_date = starts_on.strftime('%B %Y')
    end_date = ends_on.strftime('%B %Y')
    [start_date, end_date].join(' - ')
  end

  private
    def ends_on_is_after_starts_on
      return if ends_on.nil? || starts_on.nil?
      errors.add(:ends_on, :must_be_after_starts_on) if ends_on < starts_on
    end
end
