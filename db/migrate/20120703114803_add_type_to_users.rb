class AddTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :type, :string
    add_index :users, :type
    User.update_all(type: 'LenderUser')
  end
end
