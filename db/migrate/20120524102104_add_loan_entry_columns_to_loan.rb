class AddLoanEntryColumnsToLoan < ActiveRecord::Migration
  def change
    add_column :loans, :declaration_signed, :boolean
    add_column :loans, :business_name, :string
    add_column :loans, :trading_name, :string
    add_column :loans, :company_registration, :string
    add_column :loans, :postcode, :string
    add_column :loans, :non_validated_postcode, :string
    add_column :loans, :branch_sortcode, :string
    add_column :loans, :generic1, :string
    add_column :loans, :generic2, :string
    add_column :loans, :generic3, :string
    add_column :loans, :generic4, :string
    add_column :loans, :generic5, :string
    add_column :loans, :town, :string
    add_column :loans, :interest_rate_type_id, :integer
    add_column :loans, :interest_rate, :decimal, precision: 5, scale: 2
    add_column :loans, :fees, :integer
    add_column :loans, :state_aid_is_valid, :boolean
  end
end
