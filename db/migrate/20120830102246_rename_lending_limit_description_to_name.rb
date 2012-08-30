class RenameLendingLimitDescriptionToName < ActiveRecord::Migration
  def change
    rename_column :lending_limits, :description, :name
  end
end
