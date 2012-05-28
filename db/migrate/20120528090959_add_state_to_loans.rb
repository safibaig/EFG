class AddStateToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :state, :string
    add_index :loans, :state
  end
end