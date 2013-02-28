class AddLastModifiedAtToLoans < ActiveRecord::Migration
  def up
    add_column :loans, :last_modified_at, :datetime

    execute <<'SQL'
      update
        loans l
      join
        (
          select
            loan_id,
            max(modified_at) max_modified_at
          from
            loan_state_changes
          group by
            loan_id
        ) lsc on lsc.loan_id = l.id
      set
        l.last_modified_at = lsc.max_modified_at
SQL
  end

  def down
    remove_column :loans, :last_modified_at
  end
end
