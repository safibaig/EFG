class LoanModification < ActiveRecord::Base
  include FormatterConcern

  define_model_callbacks :save_and_update_loan

  before_validation :set_seq, on: :create
  before_save :store_old_values
  after_save_and_update_loan :update_loan!

  belongs_to :created_by, class_name: 'User'
  belongs_to :loan

  validates_presence_of :loan, strict: true
  validates_presence_of :created_by, strict: true
  validates_presence_of :date_of_change
  validates_presence_of :modified_date, strict: true

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
  format :old_maturity_date, with: QuickDateFormatter

  def save_and_update_loan
    return false unless valid?

    transaction do
      run_callbacks :save_and_update_loan do
        save!
      end
    end

    true
  end

  private
    def set_seq
      self.seq = (LoanModification.where(loan_id: loan_id).maximum(:seq) || -1) + 1
    end

    def store_old_values
      attributes.slice(*self.class::ATTRIBUTES_FOR_LOAN).each do |name, value|
        self["old_#{name}"] = loan[name] if value.present?
      end
    end

    def update_loan!
      attributes.slice(*self.class::ATTRIBUTES_FOR_LOAN).each do |name, value|
        loan[name] = value if value.present?
      end

      loan.modified_by = created_by
      loan.save!
    end
end
