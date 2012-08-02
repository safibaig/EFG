class AddLoansCreatedById < ActiveRecord::Migration
  def up
    add_column :loans, :created_by_id, :integer
  end

  def down
    remove_column :loans, :created_by_id
  end
end
