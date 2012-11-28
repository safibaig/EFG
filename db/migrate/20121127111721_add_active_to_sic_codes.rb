class AddActiveToSicCodes < ActiveRecord::Migration
  def change
    add_column :sic_codes, :active, :boolean, default: true
  end
end
