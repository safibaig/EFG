class AddPostClaimLimitToLoanRealisation < ActiveRecord::Migration
  def change
    add_column :loan_realisations, :post_claim_limit, :boolean, default: false
  end
end