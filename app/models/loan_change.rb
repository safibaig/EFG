class LoanChange < ActiveRecord::Base
  include FormatterConcern

  belongs_to :created_by, class_name: 'User'
  belongs_to :loan

  validates_presence_of :loan
  validates_presence_of :created_by
  validates_presence_of :date_of_change, :modified_date, :seq

  format :date_of_change, with: QuickDateFormatter
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
end
