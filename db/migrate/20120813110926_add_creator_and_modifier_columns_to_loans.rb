class AddCreatorAndModifierColumnsToLoans < ActiveRecord::Migration
  def change
    # TODO: Make these not nullable.
    add_column :loans, :created_by_id, :integer  #, null: false
    add_column :loans, :modified_by_id, :integer #, null: false
  end
end
