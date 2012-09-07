class CreateSicCodes < ActiveRecord::Migration
  def change
    create_table :sic_codes do |t|
      t.string :code
      t.string :description
      t.boolean :eligible, default: false
    end

    add_index :sic_codes, :code
  end
end
