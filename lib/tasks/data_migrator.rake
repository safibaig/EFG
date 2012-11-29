namespace :db do
  namespace :data do
    desc "Run all data migrations"
    task :migrate => :environment do
      require 'efg/data_migrator'
      EFG::DataMigrator.new.run
    end
  end
end
