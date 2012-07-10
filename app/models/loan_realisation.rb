class LoanRealisation < ActiveRecord::Base

  belongs_to :realisation_statement
  belongs_to :realised_loan, class_name: 'Loan'

  validates_presence_of :realisation_statement_id, :realised_loan_id

end
