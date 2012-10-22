namespace :users do

  # row[0] => username
  # row[3] => email
  # row[4] => lender
  # row[8] => disabled?
  # row[11] => expert
  task update_accounts: :environment do
    file = File.open('import_data/active_disabled_users.csv')
    CSV.new(file, headers: true).each do |row|

      unless User.exists?(username: row[0])
        puts "!!! User #{row[0]} does not exist !!!"
        next
      end

      # Update user
      user          = User.find_by_username(row[0])
      user.email    = row[3] if row[3].present?
      user.disabled = row[8].present? && row[8].downcase == 'yes'
      user.save(validate: false)
      puts "Updated user #{user.username}, set email to #{user.email} and disabled to #{user.disabled}"

      # Set expert
      if row[11].present? && row[11].downcase == 'yes'
        lender = Lender.find_by_name!(row[4])
        if user.lender == lender
          expert       = lender.experts.new
          expert.user  = user
          expert.save! && AdminAudit.log(AdminAudit::LenderExpertAdded, expert.user, SystemUser.first)
          puts "Made #{user.username} an expert for #{row[4]}"
        else
          puts "!!! #{user.username} does not belong to #{lender.name} !!!"
        end
      end
    end
  end

  task email_active_users: :environment do
    User.where(disabled: false).find_each do |user|
      begin
        if user.email
          puts "Sending new account email to #{user.email}"
          user.send(:generate_reset_password_token!)
          UserMailer.new_account_notification(user).deliver
        else
          puts "User ##{user.id} has no email address"
        end
      rescue Exception => e
        puts "Failed to send email to #{user.email}: #{e.message}"
      end
    end
  end

end
