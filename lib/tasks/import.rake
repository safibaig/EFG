namespace :import do

  desc "Import user data (CSV files found in import_data/)"
  task users: [:environment, :lenders] do
    require 'importers'
    UserImporter.import
  end

  desc "Import lender data (CSV files found in import_data/)"
  task lenders: :environment do
    require 'importers'
    LenderImporter.import
  end

end
