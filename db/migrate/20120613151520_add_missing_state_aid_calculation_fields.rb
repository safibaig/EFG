class AddMissingStateAidCalculationFields < ActiveRecord::Migration
  def up
    add_column :state_aid_calculations, :legacy_loan_id, :string
    add_column :state_aid_calculations, :seq, :integer
    add_column :state_aid_calculations, :loan_version, :integer
    add_column :state_aid_calculations, :calc_type, :string
    add_column :state_aid_calculations, :premium_cheque_month, :string
    add_column :state_aid_calculations, :holiday, :integer
    add_column :state_aid_calculations, :total_cost, :integer
    add_column :state_aid_calculations, :public_funding, :integer
    add_column :state_aid_calculations, :obj1_area, :boolean
    add_column :state_aid_calculations, :reduce_costs, :boolean
    add_column :state_aid_calculations, :improve_prod, :boolean
    add_column :state_aid_calculations, :increase_quality, :boolean
    add_column :state_aid_calculations, :improve_nat_env, :boolean
    add_column :state_aid_calculations, :promote, :boolean
    add_column :state_aid_calculations, :agriculture, :boolean
    add_column :state_aid_calculations, :guarantee_rate, :integer
    add_column :state_aid_calculations, :npv, :decimal, :precision => 2, :scale => 1
    add_column :state_aid_calculations, :prem_rate, :decimal, :precision => 2, :scale => 1
    add_column :state_aid_calculations, :euro_conv_rate, :decimal, :precision => 17, :scale => 14
    add_column :state_aid_calculations, :elsewhere_perc, :integer
    add_column :state_aid_calculations, :obj1_perc, :integer
    add_column :state_aid_calculations, :ar_timestamp, :datetime
    add_column :state_aid_calculations, :ar_insert_timestamp, :datetime

    add_index :state_aid_calculations, :legacy_loan_id
  end

  def down
    remove_column :state_aid_calculations, :legacy_loan_id
    remove_column :state_aid_calculations, :seq
    remove_column :state_aid_calculations, :loan_version
    remove_column :state_aid_calculations, :calc_type
    remove_column :state_aid_calculations, :premium_cheque_month
    remove_column :state_aid_calculations, :holiday
    remove_column :state_aid_calculations, :total_cost
    remove_column :state_aid_calculations, :public_funding
    remove_column :state_aid_calculations, :obj1_area
    remove_column :state_aid_calculations, :reduce_costs
    remove_column :state_aid_calculations, :improve_prod
    remove_column :state_aid_calculations, :increase_quality
    remove_column :state_aid_calculations, :improve_nat_env
    remove_column :state_aid_calculations, :promote
    remove_column :state_aid_calculations, :agriculture
    remove_column :state_aid_calculations, :guarantee_rate
    remove_column :state_aid_calculations, :npv
    remove_column :state_aid_calculations, :prem_rate
    remove_column :state_aid_calculations, :euro_conv_rate
    remove_column :state_aid_calculations, :elsewhere_perc
    remove_column :state_aid_calculations, :obj1_perc
    remove_column :state_aid_calculations, :ar_timestamp
    remove_column :state_aid_calculations, :ar_insert_timestamp
  end
end
