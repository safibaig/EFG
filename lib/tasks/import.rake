namespace :import do

  desc "Import user data (CSV files found in import_data/users.csv)"
  task users: [:environment, :lenders] do
    require 'importers'
    UserImporter.import
  end

  desc "Import lender data (CSV files found in import_data/lenders.csv)"
  task lenders: :environment do
    require 'importers'
    LenderImporter.import
  end

  desc "Import loan data (CSV files found in import_data/loans.csv)"
  task loans: [:environment, :users] do
    require 'importers'
    LoanImporter.import
  end

end
