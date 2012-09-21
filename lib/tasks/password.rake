namespace :password do
  desc "Force password reset for all users"
  task reset: :environment do
    # This is sufficient; the password_salt will be changed when the
    # new password is set.
    User.update_all(:encrypted_password => nil)
  end
end