# passwords are blank for new users
class ChangeUsersEncryptedPasswordToBeNullable < ActiveRecord::Migration
  def up
    change_column :users, :encrypted_password, :string, null: true
  end

  def down
    change_column :users, :encrypted_password, :string, null: false
  end
end
