class LoanAllocation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :lender

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation

  format :allocation, with: MoneyFormatter

end
