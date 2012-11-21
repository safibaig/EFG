class LoanStateChange < ActiveRecord::Base

  belongs_to :loan
  belongs_to :modified_by, class_name: "User"

  validates_presence_of :loan, strict: true
  validates_presence_of :state, strict: true
  validates_presence_of :modified_by_id, strict: true
  validates_presence_of :modified_at, strict: true
  validates_inclusion_of :event_id, in: LoanEvent.ids, strict: true

  attr_accessible :loan_id, :state, :modified_at, :modified_by, :modified_by_id, :event_id, :version

  def self.log(loan, event, modifier)
    create!(
      loan_id: loan.id,
      state: loan.state,
      modified_at: Time.now,
      modified_by: modifier,
      event_id: event.id
    )
  end

  def event
    LoanEvent.find(event_id)
  end

end
