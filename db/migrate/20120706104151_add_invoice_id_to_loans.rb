class AddInvoiceIdToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :invoice_id, :integer
  end
end