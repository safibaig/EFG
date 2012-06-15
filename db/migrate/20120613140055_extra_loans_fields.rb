class ExtraLoansFields < ActiveRecord::Migration
  def change
    add_column :loans, :legacy_id, :integer
    add_column :loans, :reference, :string
    add_column :loans, :created_by_legacy_id, :string
    add_column :loans, :version, :integer
    add_column :loans, :guaranteed_on, :date
    add_column :loans, :modified_by_legacy_id, :string
    add_column :loans, :lender_legacy_id, :integer
    add_column :loans, :outstanding_amount, :integer
    add_column :loans, :standard_cap, :boolean
    add_column :loans, :next_change_history_seq, :integer
    add_column :loans, :borrower_demand_outstanding, :integer
    add_column :loans, :realised_money_date, :date
    add_column :loans, :event_legacy_id, :integer
    add_column :loans, :state_aid, :integer
    add_column :loans, :ar_timestamp, :datetime
    add_column :loans, :ar_insert_timestamp, :datetime
    add_column :loans, :notified_aid, :boolean
    add_column :loans, :remove_guarantee_outstanding_amount, :integer
    add_column :loans, :remove_guarantee_on, :date
    add_column :loans, :remove_guarantee_reason, :string
    add_column :loans, :dti_amount_claimed, :integer
    add_column :loans, :invoice_legacy_id, :integer
    add_column :loans, :settled_on, :date
    add_column :loans, :next_borrower_demand_seq, :integer
    add_column :loans, :sic_desc, :string
    add_column :loans, :sic_parent_desc, :string
    add_column :loans, :sic_notified_aid, :boolean
    add_column :loans, :sic_eligible, :boolean
    add_column :loans, :non_val_postcode, :string, :limit => 10
    add_column :loans, :transferred_from, :integer
    add_column :loans, :next_in_calc_seq, :integer
    add_column :loans, :loan_source, :string, :limit => 1
    add_column :loans, :dit_break_costs, :integer
    add_column :loans, :guarantee_rate, :decimal, precision: 16, scale: 2
    add_column :loans, :premium_rate, :decimal, precision: 16, scale: 2
    add_column :loans, :legacy_small_loan, :boolean
    add_column :loans, :next_in_realise_seq, :integer
    add_column :loans, :next_in_recover_seq, :integer
    add_column :loans, :recovery_on, :date
    add_column :loans, :recovery_statement_legacy_id, :integer
    add_column :loans, :dti_interest, :integer
    add_column :loans, :loan_scheme, :string, :limit => 1
    add_column :loans, :business_type, :integer
    add_column :loans, :payment_period, :integer
    add_column :loans, :security_proportion, :decimal, precision: 5, scale: 2
    add_column :loans, :current_refinanced_value, :decimal, precision: 16, scale: 2
    add_column :loans, :final_refinanced_value, :decimal, precision: 16, scale: 2
    add_column :loans, :original_overdraft_proportion, :decimal, precision: 5, scale: 2
    add_column :loans, :refinance_security_proportion, :decimal, precision: 5, scale: 2
    add_column :loans, :overdraft_limit, :integer
    add_column :loans, :overdraft_maintained, :boolean
    add_column :loans, :invoice_discount_limit, :integer
    add_column :loans, :debtor_book_coverage, :decimal, precision: 5, scale: 2
    add_column :loans, :debtor_book_topup, :decimal, precision: 5, scale: 2
  end
end
