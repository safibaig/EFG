class LoanModification < ActiveRecord::Base
  include FormatterConcern

  define_model_callbacks :save_and_update_loan

  before_validation :set_seq, on: :create

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

  scope :desc, order('date_of_change DESC, id DESC')

  def changes
    attributes.select { |key, value|
      key[0..3] == 'old_' && value.present?
    }.keys.map { |name|
      old_name = name.sub(/_id$/, '')
      new_name = old_name.slice(4..-1)

      {
        old_attribute: old_name,
        old_value: self.send(old_name),
        attribute: new_name,
        value: self.send(new_name)
      }
    }
  end

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
end
