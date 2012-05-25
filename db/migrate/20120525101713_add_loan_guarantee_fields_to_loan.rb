class AddLoanGuaranteeFieldsToLoan < ActiveRecord::Migration
  def change
    add_column :loans, :received_declaration, :boolean
    add_column :loans, :signed_direct_debit_received, :boolean
    add_column :loans, :first_pp_received, :boolean
    add_column :loans, :initial_draw_date, :date
    add_column :loans, :initial_draw_value, :integer
    add_column :loans, :maturity_date, :date
  end
end
