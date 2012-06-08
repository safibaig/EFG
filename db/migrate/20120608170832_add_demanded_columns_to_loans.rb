class AddDemandedColumnsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :dti_demanded_on, :date
    add_column :loans, :dti_demand_outstanding, :integer
    add_column :loans, :dti_reason, :text
  end
end
