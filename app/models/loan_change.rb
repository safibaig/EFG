class LoanChange < ActiveRecord::Base
  include FormatterConcern

  attr_accessor :state_aid_calculation_attributes

  VALID_LOAN_STATES = [Loan::Guaranteed, Loan::LenderDemand]
  OLD_ATTRIBUTES_TO_STORE = %w(maturity_date business_name amount
    guaranteed_date initial_draw_date initial_draw_amount sortcode
    dti_demand_out_amount dti_demand_interest cap_id loan_term)

  belongs_to :created_by, class_name: 'User'
  belongs_to :loan

  before_validation :set_seq, on: :create
  before_save :store_old_values, on: :create

  validates_presence_of :loan
  validates_presence_of :created_by
  validates_presence_of :date_of_change, :modified_date
  validates_inclusion_of :change_type_id, in: ChangeType.all.map(&:id)

  validate :validate_change_type
  validate :validate_non_negative_amounts
  validate :state_aid_recalculated, if: :requires_state_aid_recalculation?

  format :date_of_change, with: QuickDateFormatter
  format :maturity_date, with: QuickDateFormatter
  format :modified_date, with: QuickDateFormatter
  format :lump_sum_repayment, with: MoneyFormatter.new
  format :amount_drawn, with: MoneyFormatter.new
  format :amount, with: MoneyFormatter.new
  format :old_amount, with: MoneyFormatter.new
  format :initial_draw_amount, with: MoneyFormatter.new
  format :old_initial_draw_amount, with: MoneyFormatter.new
  format :dti_demand_out_amount, with: MoneyFormatter.new
  format :old_dti_demand_out_amount, with: MoneyFormatter.new
  format :dti_demand_interest, with: MoneyFormatter.new
  format :old_dti_demand_interest, with: MoneyFormatter.new

  attr_accessible :amount_drawn, :business_name, :date_of_change,
    :change_type_id, :lump_sum_repayment, :maturity_date

  def change_type
    ChangeType.find(change_type_id)
  end

  def changes
    attributes.slice(*OLD_ATTRIBUTES_TO_STORE).select { |_, value|
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
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def requires_state_aid_recalculation?
    %w(2 3 4 6 8 a).include?(change_type_id)
  end

  private
    def set_seq
      self.seq = (LoanChange.where(loan_id: loan_id).maximum(:seq) || -1) + 1
    end

    def store_old_values
      attributes.slice(*OLD_ATTRIBUTES_TO_STORE).each do |name, value|
        self["old_#{name}"] = loan[name] if value.present?
      end
    end

    def update_loan!
      changes.each do |change|
        loan[change[:attribute]] = change[:value]
      end

      loan.state = Loan::Guaranteed
      loan.save!

      if requires_state_aid_recalculation?
        state_aid_calculation = loan.state_aid_calculations.build(state_aid_calculation_attributes)
        state_aid_calculation.calc_type = StateAidCalculation::RESCHEDULE_TYPE
        state_aid_calculation.save!
      end
    end

    def validate_change_type
      case change_type_id
      when '1'
        errors.add(:business_name, :required) unless business_name.present?
      when '5'
        errors.add(:base, :required_lender_demand_satisfied) unless amount_drawn.present? || lump_sum_repayment.present? || maturity_date.present?
      when '7'
        errors.add(:amount_drawn, :required) unless amount_drawn
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
