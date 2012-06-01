class AddLegalFormIdToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :legal_form_id, :integer
  end
end