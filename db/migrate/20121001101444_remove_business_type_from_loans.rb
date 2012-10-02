class RemoveBusinessTypeFromLoans < ActiveRecord::Migration
  def up
    execute 'UPDATE loans SET legal_form_id = business_type WHERE business_type IS NOT NULL'
    remove_column :loans, :business_type
  end

  def down
    add_column :loans, :business_type, :integer
    execute 'UPDATE loans SET business_type = legal_form_id'
  end
end
