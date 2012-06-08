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

  def lending_limit_details
    loan.lender_cap.name
  end
end
