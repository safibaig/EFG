require 'active_model/model'

class LoanChangePresenter
  extend  ActiveModel::Callbacks
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  def self.model_name
    ActiveModel::Name.new(self, nil, 'LoanChange')
  end

  define_model_callbacks :save

  before_save :update_loan_change
  before_save :update_loan

  attr_accessor :created_by
  attr_reader :date_of_change, :loan
  attr_accessible :date_of_change, :initial_draw_amount, :second_draw_amount,
    :second_draw_months, :third_draw_amount, :third_draw_months,
    :fourth_draw_amount, :fourth_draw_months

  validates :created_by, presence: true, strict: true
  validates :date_of_change, presence: true

  delegate :initial_draw_amount, :initial_draw_amount=, to: :premium_schedule
  delegate :second_draw_amount, :second_draw_amount=, to: :premium_schedule
  delegate :second_draw_months, :second_draw_months=, to: :premium_schedule
  delegate :third_draw_amount, :third_draw_amount=, to: :premium_schedule
  delegate :third_draw_months, :third_draw_months=, to: :premium_schedule
  delegate :fourth_draw_amount, :fourth_draw_amount=, to: :premium_schedule
  delegate :fourth_draw_months, :fourth_draw_months=, to: :premium_schedule

  def initialize(loan)
    @loan = loan
  end

  def attributes=(attributes)
    sanitize_for_mass_assignment(attributes).each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def date_of_change=(value)
    @date_of_change = QuickDateFormatter.parse(value)
  end

  def loan_change
    @loan_change ||= loan.loan_changes.new
  end

  def next_premium_cheque_month
    initial_draw_date.advance(months: number_of_months_from_start_date_to_next_collection).strftime('%m/%Y')
  end

  def persisted?
    false
  end

  def premium_schedule
    @premium_schedule ||= loan.premium_schedules.new do |premium_schedule|
      premium_schedule.calc_type = PremiumSchedule::RESCHEDULE_TYPE
    end
  end

  def repayment_duration_at_next_premium
    loan.repayment_duration.total_months - number_of_months_from_start_date_to_next_collection
  end

  def save
    return false unless valid?

    loan.transaction do
      run_callbacks :save do
        loan_change.created_by = created_by
        loan_change.date_of_change = date_of_change
        loan_change.modified_date = Date.current
        loan_change.save!

        premium_schedule.save!

        loan.last_modified_at = Time.now
        loan.modified_by = created_by
        loan.save!
      end
    end

    true
  end

  def valid?
    super

    premium_schedule.premium_cheque_month = next_premium_cheque_month
    premium_schedule.repayment_duration = repayment_duration_at_next_premium

    if premium_schedule.invalid?
      premium_schedule.errors.each do |key, message|
        errors.add(key, message)
      end
    end

    errors.empty?
  end

  private
    def initial_draw_date
      loan.initial_draw_change.date_of_change
    end

    def number_of_months_from_start_date_to_next_collection
      today = Date.today
      today_months = today.year * 12 + today.month
      initial_draw_date_months = initial_draw_date.year * 12 + initial_draw_date.month
      difference_in_months = today_months - initial_draw_date_months

      months = (difference_in_months.to_f / 3).ceil * 3
      months += 3 if today.beginning_of_month == initial_draw_date.advance(months: months).beginning_of_month
      months
    end

    def update_loan
    end

    def update_loan_change
    end
end
