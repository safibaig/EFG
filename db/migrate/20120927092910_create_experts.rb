class CreateExperts < ActiveRecord::Migration
  def change
    create_table :experts do |t|
      t.integer :lender_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    add_index :experts, :lender_id
    add_index :experts, :user_id, unique: true
  end
end
