class AddLegacyEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :legacy_email, :string
  end
end
