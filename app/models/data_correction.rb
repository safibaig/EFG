class DataCorrection < LoanModification
  ATTRIBUTES_FOR_OLD = %w(amount facility_letter_date initial_draw_amount
    initial_draw_date lending_limit_id sortcode)

  before_validation :set_change_type_id
  before_save :set_all_attributes
  after_save_and_update_loan :update_loan_and_initial_draw_change!
  after_save_and_update_loan :create_loan_state_change!

  validate :presence_of_a_field
  validate :validate_amount, if: :amount?
  validate :validate_facility_letter_date, if: :facility_letter_date?
  validate :validate_initial_draw_amount, if: :initial_draw_amount?
  validate :validate_initial_draw_date, if: :initial_draw_date?

  attr_accessible :amount, :facility_letter_date, :initial_draw_amount,
    :initial_draw_date, :lending_limit_id, :sortcode

  delegate :initial_draw_change, to: :loan

  def change_type_name
    'Data correction'
  end

  def lending_limit
    LendingLimit.where(id: lending_limit_id).first
  end

  def old_lending_limit
    LendingLimit.where(id: old_lending_limit_id).first
  end

  private
    def amount_ineligible?
      # TODO: Extract this duplicated business logic.
      !amount.between?(Money.new(1_000_00), Money.new(1_000_000_00))
    end

    def amount_less_than_cumulative_amount_drawn?
      amount < cumulative_drawn_amount
    end

    def amount_unchanged?
      amount == loan.amount
    end

    def create_loan_state_change!
      LoanStateChange.create!(
        loan_id: loan.id,
        state: loan.state,
        modified_on: Date.today,
        modified_by: created_by,
        event_id: 22
      )
    end

    def cumulative_drawn_amount
      if initial_draw_amount
        loan.cumulative_drawn_amount - initial_draw_change.amount_drawn + initial_draw_amount
      else
        loan.cumulative_drawn_amount
      end
    end

    def facility_letter_date_does_not_fall_within_lending_limit?
      lending_limit_for_check = lending_limit || loan.lending_limit
      starts_on = lending_limit_for_check.starts_on
      ends_on = lending_limit_for_check.ends_on

      !facility_letter_date.between?(starts_on, ends_on)
    end

    def facility_letter_date_in_future?
      facility_letter_date > Date.current
    end

    def facility_letter_date_more_than_six_months_before_initial_draw_date?
      six_months_before_initial_draw_date = (
        initial_draw_date || initial_draw_change.date_of_change
      ).months_ago(6)

      facility_letter_date < six_months_before_initial_draw_date
    end

    def initial_draw_amount_takes_cumulative_amount_drawn_over_amount?
      cumulative_drawn_amount > (amount || loan.amount)
    end

    def initial_draw_date_before_facility_letter_date?
      initial_draw_date < (facility_letter_date || loan.facility_letter_date)
    end

    def initial_draw_date_in_future?
      initial_draw_date > Date.current
    end

    def presence_of_a_field
      all_blank = [
        amount,
        facility_letter_date,
        initial_draw_amount,
        initial_draw_date,
        lending_limit_id,
        sortcode
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
        when 'initial_draw_amount'
          self.old_initial_draw_amount = initial_draw_change.amount_drawn
          initial_draw_change.amount_drawn = initial_draw_amount
        when 'initial_draw_date'
          self.old_initial_draw_date = initial_draw_change.date_of_change
          initial_draw_change.date_of_change = initial_draw_date
        when 'lending_limit_id'
          self.old_lending_limit_id = loan.lending_limit_id
          # TODO: Don't allow setting another lender's lending limit.
          loan.lending_limit = LendingLimit.find(value)
        else
          self["old_#{key}"] = loan[key] if value.present?
          loan[key] = value
        end
      end
    end

    def update_loan_and_initial_draw_change!
      loan.modified_by = created_by
      loan.save!

      initial_draw_change.save! if initial_draw_amount || initial_draw_date
    end

    def validate_amount
      if amount_unchanged?
        errors.add(:amount, :must_have_changed)
      elsif amount_ineligible?
        errors.add(:amount, :must_be_eligible_amount)
      elsif amount_less_than_cumulative_amount_drawn?
        errors.add(:amount, :must_be_gte_cumulative_amount_drawn)
      end
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

    def validate_initial_draw_amount
      if initial_draw_amount_takes_cumulative_amount_drawn_over_amount?
        errors.add(:initial_draw_amount, :must_not_take_cumulative_amount_drawn_over_amount)
      end
    end

    def validate_initial_draw_date
      if initial_draw_date_in_future?
        errors.add(:initial_draw_date, :must_not_be_in_the_future)
      elsif initial_draw_date_before_facility_letter_date?
        errors.add(:initial_draw_date, :must_not_be_before_facility_letter_date)
      end
    end
end
