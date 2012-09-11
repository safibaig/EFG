class DataCorrection < LoanModification
  ATTRIBUTES_FOR_LOAN = %w(amount facility_letter_date lending_limit_id
    sortcode)
  ATTRIBUTES_FOR_INITIAL_CHANGE = %w(initial_draw_amount initial_draw_date)

  before_validation :set_change_type_id
  after_save_and_update_loan :update_initial_draw_change!
  after_save_and_update_loan :create_loan_state_change!

  validate :presence_of_a_field
  validate :validate_amount, if: :amount?

  attr_accessible :amount, :facility_letter_date, :initial_draw_amount,
    :initial_draw_date, :lending_limit_id, :sortcode

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

    def update_initial_draw_change!
      initial_change_attributes = attributes
        .slice(*ATTRIBUTES_FOR_INITIAL_CHANGE)
        .select { |_, value| value.present? }

      if initial_change_attributes.any?
        initial_draw_change = loan.initial_draw_change

        initial_change_attributes.each do |key, value|
          initial_draw_change[key] = value
        end

        initial_draw_change.save!
      end
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
