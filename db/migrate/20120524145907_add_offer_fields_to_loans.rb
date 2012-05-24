class AddOfferFieldsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :facility_letter_sent, :boolean
    add_column :loans, :facility_letter_date, :date
  end
end
