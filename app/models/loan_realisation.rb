# Legacy 'SFLG_LOAN_REALISE_MONEY' table schema mapping:
#
#  MODIFIED_DATE => updated_at
#  REALISED_DATE => created_at
#
class LoanRealisation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :realisation_statement
  belongs_to :realised_loan, class_name: 'Loan'
  belongs_to :created_by, class_name: 'User'

  validates_presence_of :realisation_statement_id, :realised_loan_id, :created_by, :realised_amount

  attr_accessible :realised_loan, :created_by, :realised_amount

  format :realised_amount, with: MoneyFormatter.new

end
