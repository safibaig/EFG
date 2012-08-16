class LendersAreCreatedAndModifiedBySomeone < ActiveRecord::Migration
  def up
    rename_column :lenders, :created_by, :created_by_legacy_id
    rename_column :lenders, :modified_by, :modified_by_legacy_id

    add_column :lenders, :created_by_id, :integer
    add_column :lenders, :modified_by_id, :integer

    user_id = User.first.id
    Lender.update_all(
      created_by_id: user_id,
      modified_by_id: user_id
    )

    # TODO: Can't make these fields NOT NULL until after the importers have
    # been run.
    # change_column_null :lenders, :created_by_id, false
    # change_column_null :lenders, :modified_by_id, false
  end

  def down
    remove_column :lenders, :created_by_id
    remove_column :lenders, :modified_by_id
    rename_column :lenders, :created_by_legacy_id, :created_by
    rename_column :lenders, :modified_by_legacy_id, :modified_by
  end
end
