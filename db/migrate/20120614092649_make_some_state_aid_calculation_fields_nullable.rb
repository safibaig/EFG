class MakeSomeStateAidCalculationFieldsNullable < ActiveRecord::Migration
  def up
    change_column_null :state_aid_calculations, :initial_draw_year, true
    change_column_null :state_aid_calculations, :initial_draw_months, true
  end

  def down
    change_column_null :state_aid_calculations, :initial_draw_year, false
    change_column_null :state_aid_calculations, :initial_draw_months, false
  end
end
