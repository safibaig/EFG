class AddIndexToLoansReference < ActiveRecord::Migration
  def change
    add_index :loans, :reference, unique: true
  end
end
