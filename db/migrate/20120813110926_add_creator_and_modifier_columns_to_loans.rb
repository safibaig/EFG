class AddCreatorAndModifierColumnsToLoans < ActiveRecord::Migration
  def up
    add_column :loans, :created_by_id, :integer
    add_column :loans, :modified_by_id, :integer

    Loan.update_all(
      created_by_id: -1,
      modified_by_id: -1
    )

    change_column_null :loans, :created_by_id, false
    change_column_null :loans, :modified_by_id, false
  end

  def down
    remove_column :loans, :created_by_id
    remove_column :loans, :modified_by_id
  end
end
