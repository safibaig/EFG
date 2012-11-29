class CreateDataMigrationRecords < ActiveRecord::Migration
  def up
    create_table :data_migration_records do |t|
      t.string :version
      t.timestamps
    end
    add_index :data_migration_records, :version, unique: true
  end

  def down
    drop_table :data_migration_records
  end
end
