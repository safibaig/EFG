namespace :data do

  desc "Extract data from the database"
  task extract: :environment do
    require "extract"
    Extracter.run
  end

end