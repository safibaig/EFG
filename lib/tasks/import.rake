namespace :import do
  desc "Import user data (CSV files found in import_data/users.csv)"
  task users: :lenders do
    _import User
  end

  desc "Import lender data (CSV files found in import_data/lenders.csv)"
  task lenders: :environment do
    _import Lender
  end

  desc "Import loan data (CSV files found in import_data/loans.csv)"
  task loans: :lenders do
    _import Loan
  end

  desc "Import loan data (CSV files found in import_data/loans.csv)"
  task state_aid_calculations: :loans do
    _import StateAidCalculation
  end

  def _import(klass)
    if klass.count.zero?
      require 'importers'
      importer = "#{klass.name}Importer".constantize
      importer.import
    else
      puts "Did not import #{klass.table_name} - table is not empty."
    end
  end
end
