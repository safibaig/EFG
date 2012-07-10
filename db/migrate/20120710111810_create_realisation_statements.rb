class CreateRealisationStatements < ActiveRecord::Migration
  def change
    create_table :realisation_statements do |t|
      t.integer :lender_id
      t.integer :created_by_id
      t.string :reference
      t.string :period_covered_quarter
      t.string :period_covered_year
      t.date :received_on
      t.timestamps
    end
  end
end
