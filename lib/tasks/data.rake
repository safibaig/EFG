namespace :data do

  desc "Extract and cleanse to IL0 data from the database"
  task extract: :environment do
    require "extract"
    Extractor.run
  end

end