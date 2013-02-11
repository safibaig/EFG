class AddLenderReferenceToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :lender_reference, :string
  end
end
