class IndexLoansByLegacyId < ActiveRecord::Migration
  def up
    add_index :loans, :legacy_id, unique: true
  end

  def down
    remove_index :loans, :legacy_id
  end
end
