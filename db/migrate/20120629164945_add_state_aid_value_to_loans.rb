class AddStateAidValueToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :state_aid_value, :integer
  end
end