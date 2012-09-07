class AddLegacySicFieldsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :legacy_sic_code, :string
    add_column :loans, :legacy_sic_desc, :string
    add_column :loans, :legacy_sic_parent_desc, :string
    add_column :loans, :legacy_sic_notified_aid, :boolean, default: false
    add_column :loans, :legacy_sic_eligible, :boolean, default: false
  end
end
