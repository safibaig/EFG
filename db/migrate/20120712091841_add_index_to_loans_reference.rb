class AddIndexToLoansReference < ActiveRecord::Migration
  def change
    add_index :loans, :reference
  end
end
