class AddTransferredFromLegacyIdToLoans < ActiveRecord::Migration
  def change
    rename_column :loans, :transferred_from, :transferred_from_legacy_id
    add_column :loans, :transferred_from_id, :integer
  end
end
