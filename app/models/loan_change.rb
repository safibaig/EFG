class LoanChange < LoanModification
  attr_accessor :premium_schedule_attributes

  before_save :set_old_and_loan_attributes
  after_save_and_update_loan :update_loan!
  after_save_and_update_loan :log_loan_state_change!

  validates_inclusion_of :change_type_id, in: ChangeType.for_loan_change.map(&:id)

  validate :validate_change_type
  validate :validate_non_negative_amounts
  validate :state_aid_recalculated, if: :requires_state_aid_recalculation?

  attr_accessible :amount_drawn, :change_type_id,
    :date_of_change, :lump_sum_repayment, :maturity_date

  def requires_state_aid_recalculation?
    [
      ChangeType::CapitalRepaymentHoliday,
      ChangeType::ChangeRepayments,
      ChangeType::ExtendTerm,
      ChangeType::LumpSumRepayment,
      ChangeType::ReprofileDraws,
      ChangeType::DecreaseTerm,
    ].include?(change_type)
  end

  private
    def log_loan_state_change!
      LoanStateChange.log(loan, LoanEvent::ChangeAmountOrTerms, created_by)
    end

    def set_old_and_loan_attributes
      case change_type
      when ChangeType::ExtendTerm, ChangeType::DecreaseTerm
        self.old_maturity_date  = loan.maturity_date
        loan.maturity_date      = maturity_date
        self.old_repayment_duration      = loan.repayment_duration.total_months
        new_repayment_duration           = RepaymentDuration.new(loan).months_between_draw_date_and_maturity_date
        self.repayment_duration          = new_repayment_duration
        loan.repayment_duration = new_repayment_duration
      end
    end

    def update_loan!
      loan.modified_by = created_by
      loan.state = Loan::Guaranteed
      loan.save!

      if requires_state_aid_recalculation?
        premium_schedule = loan.premium_schedules.build(premium_schedule_attributes)
        premium_schedule.calc_type = PremiumSchedule::RESCHEDULE_TYPE
        premium_schedule.save!
      end
    end

    def validate_change_type
      case change_type
      when ChangeType::ExtendTerm, ChangeType::DecreaseTerm
        errors.add(:maturity_date, :required) unless maturity_date
        validate_maturity_date_within_allowed_repayment_duration if maturity_date
      when ChangeType::LenderDemandSatisfied
        errors.add(:base, :required_lender_demand_satisfied) unless amount_drawn || lump_sum_repayment || maturity_date.present?
      when ChangeType::LumpSumRepayment
        errors.add(:lump_sum_repayment, :required) unless lump_sum_repayment
        if lump_sum_repayment && (loan.cumulative_lump_sum_amount + lump_sum_repayment) > loan.cumulative_drawn_amount
          errors.add(:lump_sum_repayment, :exceeds_amount_drawn)
        end
      when ChangeType::RecordAgreedDraw
        errors.add(:amount_drawn, :required) unless amount_drawn
        errors.add(:amount_drawn, :exceeded_undrawn_amount) if amount_drawn && amount_drawn > loan.amount_not_yet_drawn
      end
    end

    def validate_non_negative_amounts
      errors.add(:amount_drawn, :not_be_negative) if amount_drawn && amount_drawn < 0
      errors.add(:lump_sum_repayment, :not_be_negative) if lump_sum_repayment && lump_sum_repayment < 0
    end

    def state_aid_recalculated
      errors.add(:base, :state_aid_not_recalculated) unless premium_schedule_attributes.present?
    end

    def validate_maturity_date_within_allowed_repayment_duration
      repayment_duration = RepaymentDuration.new(loan)
      initial_draw_date = loan.initial_draw_change.date_of_change

      if maturity_date < initial_draw_date.advance(months: repayment_duration.min_months)
        errors.add(:maturity_date, :less_than_min_repayment_duration)
      end

      if maturity_date > initial_draw_date.advance(months: repayment_duration.max_months)
        errors.add(:maturity_date, :greater_than_max_repayment_duration)
      end
    end
end
