class LoanStateChange < ActiveRecord::Base

  belongs_to :loan
  belongs_to :modified_by, class_name: "User"

  validates_presence_of :loan_id, :state, :event_id, :modified_on, :modified_by_id

end
