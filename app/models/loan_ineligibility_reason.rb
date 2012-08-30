class LoanIneligibilityReason < ActiveRecord::Base

  belongs_to :loan

  validates_presence_of :loan_id, :reason

  attr_accessible :loan_id, :reason

end
