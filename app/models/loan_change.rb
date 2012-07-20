class LoanChange < ActiveRecord::Base
  include FormatterConcern

  OLD_ATTRIBUTES_TO_STORE = %w(maturity_date business_name amount
    guaranteed_date initial_draw_date initial_draw_amount sortcode
    dti_demand_out_amount dti_demand_interest cap_id loan_term)

  belongs_to :created_by, class_name: 'User'
  belongs_to :loan

  before_save :store_old_values, on: :create

  validates_presence_of :loan
  validates_presence_of :created_by
  validates_presence_of :change_type_id, :date_of_change, :modified_date, :seq

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

  private
    def store_old_values
      attributes.slice(*OLD_ATTRIBUTES_TO_STORE).each do |name, value|
        if value.present?
          old_name = "old_#{name}"
          self[old_name] = loan[name]
        end
      end
    end
end
