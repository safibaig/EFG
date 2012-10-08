class LoanOffer
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Completed, to: Loan::Offered, event: :offer_scheme_facility

  attribute :facility_letter_date
  attribute :facility_letter_sent

  delegate :lending_limit, to: :loan

  validates_presence_of :facility_letter_date

  validate :lending_limit_is_active, if: :not_legacy_or_transferred_loan?

  validate :lending_limit_expired_less_than_six_months_ago, if: :not_legacy_or_transferred_loan?

  validate :facility_letter_date_within_lending_limit_dates, if: :not_legacy_or_transferred_loan?

  validate do
    errors.add(:facility_letter_sent, :accepted) unless self.facility_letter_sent
  end

  private

  def lending_limit_is_active
    errors.add(:base, :lending_limit_inactive) unless lending_limit.active?
  end

  def lending_limit_expired_less_than_six_months_ago
    errors.add(:base, :lending_limit_expired) unless lending_limit.ends_on >= 6.months.ago.to_date
  end

  def facility_letter_date_within_lending_limit_dates
    return if facility_letter_date.blank?
    unless facility_letter_date.between?(lending_limit.starts_on, lending_limit.ends_on)
      errors.add(:facility_letter_date, :outside_lending_limit_dates)
    end
  end

  def not_legacy_or_transferred_loan?
    !loan.legacy_loan? && !loan.created_from_transfer?
  end
end
