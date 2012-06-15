class LoanOffer
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Completed, to: Loan::Offered

  attribute :facility_letter_date
  attribute :facility_letter_sent

  validates_presence_of :facility_letter_date

  validate do
    errors.add(:facility_letter_sent, :accepted) unless self.facility_letter_sent
  end

  # TODO - return information about the loan allocation??
  def lending_limit_details
    loan.lender.name
  end
end
