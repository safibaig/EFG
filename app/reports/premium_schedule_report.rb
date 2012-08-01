require 'active_model/model'

class PremiumScheduleReport
  LOAN_SCHEMES = ['All', 'SFLG only', 'EFG only']
  LOAN_TYPES = %w(All New Legacy)
  SCHEDULE_TYPES = %w(All New Changed)

  include ActiveModel::Model

  attr_accessor :collection_month, :lender_id, :loan_reference, :loan_scheme,
    :loan_type, :schedule_type
  attr_reader :finish_on, :start_on

  validates_format_of :collection_month, with: /\d+\/\d+/, allow_blank: true
  validate :all_the_things

  def count
    loans.count
  end

  def finish_on=(value)
    @finish_on = QuickDateFormatter.parse(value)
  end

  def lender
    Lender.find(lender_id) if lender_id.present?
  end

  def loans
    scope = Loan.scoped
    scope = scope.where(lender_id: lender_id) if lender_id.present?
    scope
  end

  def start_on=(value)
    @start_on = QuickDateFormatter.parse(value)
  end

  def to_csv
    ''
  end

  private
    def all_the_things
      if collection_month.blank? && schedule_type != 'New' && loan_reference.blank?
        errors.add(:collection_month, :required)
      end

      if finish_on.blank? && start_on.blank? && schedule_type != 'Changed'
        errors.add(:base, :start_or_finish_is_required)
      end
    end
end
