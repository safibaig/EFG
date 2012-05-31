class AddRepaymentFrequencyIdToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :repayment_frequency_id, :integer
  end
end
