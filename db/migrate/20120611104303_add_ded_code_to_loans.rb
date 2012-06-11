class AddDedCodeToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :dti_ded_code, :string
  end
end
