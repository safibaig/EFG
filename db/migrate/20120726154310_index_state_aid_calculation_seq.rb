class IndexStateAidCalculationSeq < ActiveRecord::Migration
  def up
    remove_index :state_aid_calculations, :loan_id
    add_index :state_aid_calculations, [:loan_id, :seq], unique: true
  end

  def down
    remove_index :state_aid_calculations, [:loan_id, :seq]
    add_index :state_aid_calculations, :loan_id
  end
end
