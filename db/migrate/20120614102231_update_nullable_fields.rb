# Legacy data has a lot of unpopulated fields, so remove not-nullable
# constraint on various table fields so we can happily import data
class UpdateNullableFields < ActiveRecord::Migration
  def up
    change_column :users, :lender_id, :integer, :null => true
    change_column :loans, :loan_category_id, :integer, :null => true
    change_column :loans, :personal_guarantee_required, :boolean, :null => true
    change_column :loans, :private_residence_charge_required, :boolean, :null => true
    change_column :loans, :lender_cap_id, :integer, :null => true
    change_column :loans, :reason_id, :integer, :null => true
    change_column :loans, :trading_date, :date, :null => true
    change_column :loans, :turnover, :integer, :null => true
  end

  def down
    change_column :users, :lender_id, :integer, :null => false
    change_column :loans, :loan_category_id, :integer, :null => false
    change_column :loans, :personal_guarantee_required, :boolean, :null => false
    change_column :loans, :private_residence_charge_required, :boolean, :null => false
    change_column :loans, :lender_cap_id, :integer, :null => false
    change_column :loans, :reason_id, :integer, :null => false
    change_column :loans, :trading_date, :date, :null => false
    change_column :loans, :turnover, :integer, :null => false
  end
end
