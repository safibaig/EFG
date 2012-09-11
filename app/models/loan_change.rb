class LoanChange < ActiveRecord::Base
  include FormatterConcern

  attr_accessor :state_aid_calculation_attributes

  ATTRIBUTES_FOR_INITIAL_CHANGE = %w(initial_draw_amount initial_draw_date)
  ATTRIBUTES_FOR_LOAN = %w(amount business_name lending_limit_id maturity_date
    sortcode)
  ATTRIBUTES_FOR_OLD = %w(maturity_date business_name amount
    facility_letter_date initial_draw_date initial_draw_amount sortcode
    dti_demand_out_amount dti_demand_interest lending_limit_id loan_term)

  belongs_to :created_by, class_name: 'User'
  belongs_to :loan

  before_validation :set_seq, on: :create
  before_save :store_old_values, on: :create

  validates_presence_of :loan
  validates_presence_of :created_by
  validates_presence_of :date_of_change
  validates_presence_of :modified_date
  validates_inclusion_of :change_type_id, in: ChangeType.all.map(&:id) << nil

  validate :validate_change_type
  validate :validate_non_negative_amounts
  validate :validate_amount
  validate :state_aid_recalculated, if: :requires_state_aid_recalculation?

  format :amount, with: MoneyFormatter.new
  format :amount_drawn, with: MoneyFormatter.new
  format :date_of_change, with: QuickDateFormatter
  format :dti_demand_interest, with: MoneyFormatter.new
  format :dti_demand_out_amount, with: MoneyFormatter.new
  format :facility_letter_date, with: QuickDateFormatter
  format :initial_draw_amount, with: MoneyFormatter.new
  format :initial_draw_date, with: QuickDateFormatter
  format :lump_sum_repayment, with: MoneyFormatter.new
  format :maturity_date, with: QuickDateFormatter
  format :modified_date, with: QuickDateFormatter
  format :old_amount, with: MoneyFormatter.new
  format :old_dti_demand_interest, with: MoneyFormatter.new
  format :old_dti_demand_out_amount, with: MoneyFormatter.new
  format :old_facility_letter_date, with: QuickDateFormatter
  format :old_initial_draw_amount, with: MoneyFormatter.new
  format :old_initial_draw_date, with: QuickDateFormatter

  attr_accessible :amount, :amount_drawn, :business_name, :change_type_id,
    :date_of_change, :facility_letter_date, :initial_draw_amount,
    :initial_draw_date, :lending_limit_id, :lump_sum_repayment,
    :maturity_date, :sortcode

  def change_type
    ChangeType.find(change_type_id)
  end

  def changes
    attributes.slice(*ATTRIBUTES_FOR_OLD).select { |_, value|
      value.present?
    }.keys.map { |attribute|
      old_attribute = "old_#{attribute}"

      {
        old_attribute: old_attribute,
        old_value: self[old_attribute],
        attribute: attribute,
        value: self[attribute]
      }
    }
  end

  def save_and_update_loan
    transaction do
      save!
      update_loan!
      update_initial_loan_change!
      log_loan_state_change!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def requires_state_aid_recalculation?
    %w(2 3 4 6 8 a).include?(change_type_id)
  end

  private
    def data_correction?
      change_type_id == '9'
    end

    def set_seq
      self.seq = (LoanChange.where(loan_id: loan_id).maximum(:seq) || -1) + 1
    end

    def store_old_values
      attributes.slice(*ATTRIBUTES_FOR_OLD).each do |name, value|
        self["old_#{name}"] = loan[name] if value.present?
      end
    end

    def update_initial_loan_change!
      initial_change_attributes = attributes
        .slice(*ATTRIBUTES_FOR_INITIAL_CHANGE)
        .select { |_, value| value.present? }

      if initial_change_attributes.any?
        initial_loan_change = loan.initial_loan_change

        # Ensure formatters are respected by using accessors.
        initial_change_attributes.each do |key, value|
          initial_loan_change[key] = value
        end

        initial_loan_change.save!
      end
    end

    def update_loan!
      attributes.slice(*ATTRIBUTES_FOR_LOAN).select { |_, value|
        value.present?
      }.each do |name, value|
        loan[name] = value
      end

      loan.modified_by = created_by
      loan.state = Loan::Guaranteed unless data_correction?
      loan.save!

      if requires_state_aid_recalculation?
        state_aid_calculation = loan.state_aid_calculations.build(state_aid_calculation_attributes)
        state_aid_calculation.calc_type = StateAidCalculation::RESCHEDULE_TYPE
        state_aid_calculation.save!
      end
    end

    def log_loan_state_change!
      LoanStateChange.create!(
        loan_id: loan.id,
        state: loan.state,
        modified_on: Date.today,
        modified_by: loan.modified_by,
        event_id: data_correction? ? 22 : 9
      )
    end

    def validate_change_type
      case change_type_id
      when '1'
        errors.add(:business_name, :required) unless business_name.present?
      when '5'
        errors.add(:base, :required_lender_demand_satisfied) unless amount_drawn.present? || lump_sum_repayment.present? || maturity_date.present?
      when '7'
        errors.add(:amount_drawn, :required) unless amount_drawn
      when '9'
        all_blank = [
          amount,
          facility_letter_date,
          initial_draw_amount,
          initial_draw_date,
          lending_limit_id,
          sortcode
        ].all?(&:blank?)

        errors.add(:base, :required_for_data_correction) if all_blank
      end
    end

    def validate_amount
      return if amount.blank?

      # TODO: Extract this duplicated logic.
      if amount.between?(Money.new(1_000_00), Money.new(1_000_000_00))
        total_amount_drawn = Money.new(loan.loan_changes.sum(:amount_drawn))
        errors.add(:amount, :must_be_gte_total_amount_drawn) unless amount >= total_amount_drawn
      else
        errors.add(:amount, :must_be_eligible_amount)
      end
    end

    def validate_non_negative_amounts
      errors.add(:amount_drawn, :not_be_negative) if amount_drawn && amount_drawn < 0
      errors.add(:lump_sum_repayment, :not_be_negative) if lump_sum_repayment && lump_sum_repayment < 0
    end

    def state_aid_recalculated
      errors.add(:base, :state_aid_not_recalculated) unless state_aid_calculation_attributes.present?
    end
end
