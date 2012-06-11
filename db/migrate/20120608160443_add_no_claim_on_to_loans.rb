class AddNoClaimOnToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :no_claim_on, :date
  end
end
