class AddRemainingColumnsToRealisationStatements < ActiveRecord::Migration
  def change
    add_column :realisation_statements, :version, :string
    add_column :realisation_statements, :legacy_id, :string
    add_column :realisation_statements, :legacy_lender_id, :string
    add_column :realisation_statements, :legacy_created_by, :string
    add_column :realisation_statements, :period_covered_to_date, :datetime
    add_column :realisation_statements, :ar_timestamp, :string
    add_column :realisation_statements, :ar_insert_timestamp, :string
  end
end
