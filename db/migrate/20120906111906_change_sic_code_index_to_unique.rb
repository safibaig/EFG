class ChangeSicCodeIndexToUnique < ActiveRecord::Migration
  def up
    remove_index :sic_codes, :code
    add_index :sic_codes, :code, unique: true
  end

  def down
    remove_index :sic_codes, :code
    add_index :sic_codes, :code
  end
end
