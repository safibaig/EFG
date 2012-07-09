class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :lender_id
      t.string :reference
      t.string :period_covered_quarter
      t.string :period_covered_year
      t.date :received_on
      t.integer :created_by_id

      t.timestamps
    end
  end
end
