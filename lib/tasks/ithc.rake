namespace :ithc do
  desc "Seed data for ITHC"
  task seed: :environment do
    raise "Please specify the email using 'email=foo@example.com'" unless ENV["email"]

    require 'ithc'
    base_email = ENV["email"]
    result = Ithc::Generator.seed(base_email)
    result.each do |k, v|
      if v[:created]
        puts "Created #{k} with username <#{v[:username]}>"
      else
        puts "Found existing #{k} with username <#{v[:username]}>"
      end
    end
  end
end