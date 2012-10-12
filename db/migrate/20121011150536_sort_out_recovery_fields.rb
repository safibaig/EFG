class SortOutRecoveryFields < ActiveRecord::Migration
  def up
    change_column :recoveries, :seq, :integer, null: false
    execute 'UPDATE recoveries SET total_proceeds_recovered = 0 WHERE total_proceeds_recovered IS NULL'
    change_column_null :recoveries, :total_proceeds_recovered, false
    change_column_null :recoveries, :outstanding_non_efg_debt, true
    change_column_null :recoveries, :non_linked_security_proceeds, true
    change_column_null :recoveries, :linked_security_proceeds, true
    change_column_null :recoveries, :realisations_attributable, true
  end

  def down
    change_column :recoveries, :seq, :string, null: true
    change_column_null :recoveries, :total_proceeds_recovered, true
    change_column_null :recoveries, :outstanding_non_efg_debt, false
    change_column_null :recoveries, :non_linked_security_proceeds, false
    change_column_null :recoveries, :linked_security_proceeds, false
    change_column_null :recoveries, :realisations_attributable, false
  end
end
