class RenameLoansTableDitBreakCostsField < ActiveRecord::Migration
  def change
    rename_column :loans, :dit_break_costs, :dti_break_costs
  end
end
