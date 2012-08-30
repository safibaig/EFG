class CreateDedCodes < ActiveRecord::Migration
  def change
    create_table :ded_codes do |t|
      t.string :legacy_id
      t.string :group_description
      t.string :category_description
      t.string :code
      t.string :code_description
      t.datetime :ar_timestamp
      t.datetime :ar_insert_timestamp
      t.timestamps
    end

    add_index :ded_codes, :group_description
  end
end
