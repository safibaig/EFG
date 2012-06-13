namespace :import do

  desc "Import user data (CSV files found in import_data/)"
  task users: :environment do
    require 'importers'
    UserImporter.import
  end

  desc "Import user data (CSV files found in import_data/)"
  task lenders: :environment do
    require 'importers'
    LenderImporter.import
  end

end
