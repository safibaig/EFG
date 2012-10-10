if File.exists?("#{Rails.root}/REVISION")
  revision = File.open("#{Rails.root}/REVISION") { |f| f.readline.chomp }
  CURRENT_RELEASE_SHA = revision[0..7] # Just get the short SHA
else
  CURRENT_RELEASE_SHA = "development"
end
