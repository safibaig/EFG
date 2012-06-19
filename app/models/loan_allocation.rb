class LoanAllocation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :lender

  has_many :loans

  # FIXME: update to use the correct loan states
  has_many :completed_loans,
           :class_name => "Loan",
           :conditions => ["loans.state IN (?)", [Loan::Offered, Loan::Repaid]]

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation, :starts_on, :ends_on

  format :allocation, with: MoneyFormatter

end
