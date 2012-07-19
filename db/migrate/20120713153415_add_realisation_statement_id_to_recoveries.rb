class AddRealisationStatementIdToRecoveries < ActiveRecord::Migration
  def change
    add_column :recoveries, :realisation_statement_id, :integer
  end
end
