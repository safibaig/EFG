class UpdateDedCodesIndexes < ActiveRecord::Migration
  def change
    add_index :ded_codes, :code, unique: true
    remove_index :ded_codes, :group_description
  end
end
