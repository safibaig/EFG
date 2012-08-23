class RemoveLockedAtFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :locked_at
  end

  def down
    add_column :users, :locked_at, :datetime
  end
end
