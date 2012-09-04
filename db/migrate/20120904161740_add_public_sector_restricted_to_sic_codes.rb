class AddPublicSectorRestrictedToSicCodes < ActiveRecord::Migration
  def change
    add_column :sic_codes, :public_sector_restricted, :boolean, default: false
  end
end
