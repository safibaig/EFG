class LoanSecurity < ActiveRecord::Base
  belongs_to :loan

  attr_accessible :loan_id, :loan_security_type_id

  def loan_security_type
    LoanSecurityType.find(loan_security_type_id)
  end
end
