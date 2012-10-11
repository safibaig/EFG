class SortOutRecoveryFields < ActiveRecord::Migration
  def up
    change_column :recoveries, :seq, :integer, null: false
    change_column_null :recoveries, :outstanding_non_efg_debt, true
    change_column_null :recoveries, :non_linked_security_proceeds, true
    change_column_null :recoveries, :linked_security_proceeds, true
    change_column_null :recoveries, :realisations_attributable, true
  end

  def down
    change_column :recoveries, :seq, :string, null: true
    change_column_null :recoveries, :outstanding_non_efg_debt, false
    change_column_null :recoveries, :non_linked_security_proceeds, false
    change_column_null :recoveries, :linked_security_proceeds, false
    change_column_null :recoveries, :realisations_attributable, false
  end
end
