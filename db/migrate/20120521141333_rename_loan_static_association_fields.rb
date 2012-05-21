class RenameLoanStaticAssociationFields < ActiveRecord::Migration
  def up
    rename_column :loans, :lender_cap, :lender_cap_id
    rename_column :loans, :loan_category, :loan_category_id
    rename_column :loans, :reason, :reason_id
  end

  def down
    rename_column :loans, :lender_cap_id, :lender_cap
    rename_column :loans, :loan_category_id, :loan_category
    rename_column :loans, :reason_id, :reason
  end
end
