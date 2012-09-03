class LoanOffer
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Completed, to: Loan::Offered, event: :offer_scheme_facility

  attribute :facility_letter_date
  attribute :facility_letter_sent

  delegate :lending_limit, to: :loan

  validates_presence_of :facility_letter_date

  validate do
    errors.add(:facility_letter_sent, :accepted) unless self.facility_letter_sent
  end
end
