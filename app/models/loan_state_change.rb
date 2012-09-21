class LoanStateChange < ActiveRecord::Base

  belongs_to :loan
  belongs_to :modified_by, class_name: "User"

  validates_presence_of :loan, strict: true
  validates_presence_of :state, strict: true
  validates_presence_of :modified_by_id, strict: true
  validates_presence_of :modified_on, strict: true
  validates_inclusion_of :event_id, in: LoanEvent.all.map(&:id), strict: true

  attr_accessible :loan_id, :state, :modified_on, :modified_by, :modified_by_id, :event_id, :version

  def event
    LoanEvent.find(event_id)
  end

end
