class CreateDataMigrationRecords < ActiveRecord::Migration
  def up
    create_table :data_migration_records do |t|
      t.string :version
    end
    add_index :data_migration_records, :version, unique: true
    DataMigrationRecord.create!(version: "20121126155341")
  end

  def down
    drop_table :data_migration_records
  end
end
