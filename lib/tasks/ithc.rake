namespace :ithc do
  desc "Seed data for ITHC"
  task seed: :environment do
    raise "Please specify the email using 'email=foo@example.com'" unless ENV["email"]

    require 'ithc'
    base_email = ENV["email"]
    Ithc::Generator.seed(base_email)
  end
end