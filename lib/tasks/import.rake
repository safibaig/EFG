namespace :import do

  desc "Import user data (CSV files found in import_data/)"
  task users: :environment do
    require 'importers'
    UserImporter.import
  end

end
