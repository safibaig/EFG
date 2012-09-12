class LoanChange < LoanModification
  attr_accessor :state_aid_calculation_attributes

  before_save :set_old_and_loan_attributes
  after_save_and_update_loan :update_loan!
  after_save_and_update_loan :create_loan_state_change!

  validates_inclusion_of :change_type_id, in: %w(1 2 3 4 5 6 7 8 a)

  validate :validate_change_type
  validate :validate_non_negative_amounts
  validate :state_aid_recalculated, if: :requires_state_aid_recalculation?

  attr_accessible :amount_drawn, :business_name, :change_type_id,
    :date_of_change, :lump_sum_repayment, :maturity_date

  def change_type
    ChangeType.find(change_type_id)
  end

  def requires_state_aid_recalculation?
    %w(2 3 4 6 8 a).include?(change_type_id)
  end

  private
    def create_loan_state_change!
      LoanStateChange.create!(
        loan_id: loan.id,
        state: loan.state,
        modified_on: Date.today,
        modified_by: created_by,
        event_id: 9
      )
    end

    def set_old_and_loan_attributes
      case change_type_id
      when '1'
        self.old_business_name = loan.business_name
        loan.business_name = business_name
      when 'a'
        self.old_maturity_date = loan.maturity_date
        loan.maturity_date = maturity_date
      end
    end

    def update_loan!
      loan.modified_by = created_by
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
        errors.add(:base, :required_lender_demand_satisfied) unless amount_drawn || lump_sum_repayment || maturity_date.present?
      when '7'
        errors.add(:amount_drawn, :required) unless amount_drawn
      when 'a'
        errors.add(:maturity_date, :required) unless maturity_date
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
