class LoanChange < ActiveRecord::Base
  include FormatterConcern

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
  validates_presence_of :change_type_id, :date_of_change, :modified_date

  validate :validate_change_type
  validate :validate_non_negative_amounts

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

  private
    def set_seq
      self.seq = (LoanChange.where(loan_id: loan_id).maximum(:seq) || -1) + 1
    end

    def store_old_values
      attributes.slice(*OLD_ATTRIBUTES_TO_STORE).each do |name, value|
        if value.present?
          old_name = "old_#{name}"
          self[old_name] = loan[name]
        end
      end
    end

    def update_loan!
      changes.each do |change|
        loan[change[:attribute]] = change[:value]
      end

      loan.state = Loan::Guaranteed
      loan.save!
    end

    def validate_change_type
      case change_type_id
      when '1'
        errors.add(:business_name, :required) unless business_name.present?
      when '7'
        errors.add(:amount_drawn, :required) unless amount_drawn.present?
      end
    end

    def validate_non_negative_amounts
      errors.add(:amount_drawn, :not_be_negative) if amount_drawn.present? && amount_drawn < 0
    end
end
