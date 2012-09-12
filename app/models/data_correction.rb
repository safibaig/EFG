class DataCorrection < LoanModification
  ATTRIBUTES_FOR_OLD = %w(amount facility_letter_date initial_draw_amount
    initial_draw_date lending_limit_id sortcode)

  before_validation :set_change_type_id
  before_save :set_all_attributes
  after_save_and_update_loan :update_loan_and_initial_draw_change!
  after_save_and_update_loan :create_loan_state_change!

  validate :presence_of_a_field
  validate :validate_amount, if: :amount?

  attr_accessible :amount, :facility_letter_date, :initial_draw_amount,
    :initial_draw_date, :lending_limit_id, :sortcode

  delegate :initial_draw_change, to: :loan

  private
    def create_loan_state_change!
      LoanStateChange.create!(
        loan_id: loan.id,
        state: loan.state,
        modified_on: Date.today,
        modified_by: created_by,
        event_id: 22
      )
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
      # TODO: Extract this duplicated logic.
      if amount.between?(Money.new(1_000_00), Money.new(1_000_000_00))
        errors.add(:amount, :must_be_gte_total_amount_drawn) unless amount >= loan.cumulative_drawn_amount
      else
        errors.add(:amount, :must_be_eligible_amount)
      end
    end
end
