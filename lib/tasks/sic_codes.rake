namespace :sic_codes do

  desc 'Update SIC code for existing loans to 2007 standard'
  task update_loans: :environment do
    require 'importers'
    LoanSicCodeUpdateImporter.import
  end

end
