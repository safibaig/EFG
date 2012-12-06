class DataCorrection < LoanModification

  ATTRIBUTES_FOR_OLD = %w(facility_letter_date sortcode dti_demand_out_amount
    dti_demand_interest)

  before_validation :set_change_type_id
  before_save :set_all_attributes
  after_save_and_update_loan :update_loan!
  after_save_and_update_loan :log_state_change!

  validate :presence_of_a_field
  validate :validate_facility_letter_date, if: :facility_letter_date?
  validate :validate_dti_demand_out_amount, if: :dti_demand_out_amount?
  validate :validate_dti_demand_interest, if: :dti_demand_interest?

  attr_accessible :facility_letter_date, :sortcode, :dti_demand_out_amount, :dti_demand_interest

  delegate :initial_draw_change, to: :loan

  belongs_to :old_lending_limit, class_name: 'LendingLimit'
  belongs_to :lending_limit

  def change_type_name
    'Data correction'
  end

  private
    def log_state_change!
      LoanStateChange.log(loan, LoanEvent::DataCorrection, created_by)
    end

    def facility_letter_date_does_not_fall_within_lending_limit?
      lending_limit_for_check = loan.lending_limit
      starts_on = lending_limit_for_check.starts_on
      ends_on = lending_limit_for_check.ends_on

      !facility_letter_date.between?(starts_on, ends_on)
    end

    def facility_letter_date_in_future?
      facility_letter_date > Date.current
    end

    def facility_letter_date_more_than_six_months_before_initial_draw_date?
      six_months_before_initial_draw_date = (
        initial_draw_change.date_of_change
      ).months_ago(6)

      facility_letter_date < six_months_before_initial_draw_date
    end

    def presence_of_a_field
      all_blank = [
        facility_letter_date,
        sortcode,
        dti_demand_out_amount,
        dti_demand_interest
      ].all?(&:blank?)

      errors.add(:base, :must_have_a_change) if all_blank
    end

    def set_change_type_id
      self.change_type_id = '9'
    end

    def set_all_attributes
      attributes.slice(*ATTRIBUTES_FOR_OLD).select { |_, value|
        value.present?
      }.each do |key, value|
        case key
        when 'dti_demand_out_amount'
          self.old_dti_demand_out_amount = loan.dti_demand_outstanding
          loan.dti_demand_outstanding = dti_demand_out_amount
        when 'dti_demand_interest'
          self.old_dti_demand_interest = loan.dti_interest
          loan.dti_interest = dti_demand_interest
        else
          self["old_#{key}"] = loan[key] if value.present?
          loan[key] = value
        end
      end

      if dti_demand_out_amount? || dti_demand_interest?
        loan.calculate_dti_amount_claimed
      end
    end

    def update_loan!
      loan.modified_by = created_by
      loan.save!
    end

    def validate_facility_letter_date
      if facility_letter_date_in_future?
        errors.add(:facility_letter_date, :must_not_be_in_the_future)
      elsif facility_letter_date_does_not_fall_within_lending_limit?
        errors.add(:facility_letter_date, :must_fall_within_lending_limit)
      elsif facility_letter_date_more_than_six_months_before_initial_draw_date?
        errors.add(:facility_letter_date, :must_be_no_less_than_six_months_before_initial_draw_date)
      end
    end

    def validate_dti_demand_out_amount
      if loan.state != Loan::Demanded
        errors.add(:dti_demand_out_amount, :must_be_demanded_state)
      elsif loan.dti_demand_outstanding == dti_demand_out_amount
        errors.add(:dti_demand_out_amount, :must_have_changed)
      elsif dti_demand_out_amount < Money.new(0)
        errors.add(:dti_demand_out_amount, :must_not_be_negative)
      elsif dti_demand_out_amount > loan.cumulative_drawn_amount
        errors.add(:dti_demand_out_amount, :must_not_be_greater_than_cumulative_drawn_amount)
      end
    end

    def validate_dti_demand_interest
      if loan.efg_loan?
        errors.add(:dti_demand_interest, :must_not_be_an_EFG_loan)
      elsif loan.state != Loan::Demanded
        errors.add(:dti_demand_interest, :must_be_demanded_state)
      elsif loan.dti_interest == dti_demand_interest
        errors.add(:dti_demand_interest, :must_have_changed)
      elsif dti_demand_interest < Money.new(0)
        errors.add(:dti_demand_interest, :must_not_be_negative)
      elsif amount && dti_demand_interest > amount
        errors.add(:dti_demand_interest, :must_be_lte_new_loan_amount)
      elsif dti_demand_interest > loan.amount
        errors.add(:dti_demand_interest, :must_be_lte_original_loan_amount)
      end
    end
end
