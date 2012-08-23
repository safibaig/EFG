class AddRemainingColumnsToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :legacy_id, :integer
    add_column :invoices, :version, :integer, default: 0, null: false
    add_column :invoices, :legacy_lender_oid, :integer
    add_column :invoices, :xref, :string
    add_column :invoices, :period_covered_to_date, :string
    add_column :invoices, :created_by_legacy_id, :string
    add_column :invoices, :creation_time, :string
    add_column :invoices, :ar_timestamp, :string
    add_column :invoices, :ar_insert_timestamp, :string
  end
end
