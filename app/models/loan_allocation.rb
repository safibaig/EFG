class LoanAllocation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :lender

  has_many :loans

  # FIXME: update to use the correct loan states
  has_many :completed_loans,
           class_name: "Loan",
           conditions: ["loans.state IN (?)", [Loan::Guaranteed]]

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation, :starts_on, :ends_on

  format :allocation, with: MoneyFormatter.new

  def title
    start_date = starts_on.strftime('%B %Y')
    end_date = ends_on.strftime('%B %Y')
    [start_date, end_date].join(' - ')
  end
end
