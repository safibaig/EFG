class LoanRealisation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :realisation_statement
  belongs_to :realised_loan, class_name: 'Loan'
  belongs_to :created_by, class_name: 'User'

  validates_presence_of :realisation_statement_id, :realised_loan_id, :created_by, :realised_amount

  attr_accessible :realised_loan, :created_by, :realised_amount

  scope :pre_claim_limit, -> { where(post_claim_limit: false) }
  scope :post_claim_limit, -> { where(post_claim_limit: true) }

  format :realised_amount, with: MoneyFormatter.new
end
