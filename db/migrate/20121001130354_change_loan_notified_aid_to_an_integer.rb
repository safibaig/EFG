class ChangeLoanNotifiedAidToAnInteger < ActiveRecord::Migration
  def up
    change_column :loans, :notified_aid, :integer, default: 0, null: false
  end

  def down
    change_column :loans, :notified_aid, :boolean, default: nil, null: true
  end
end
