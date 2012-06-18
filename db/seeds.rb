lender = Lender.find_or_create_by_name("Banksy")

user = User.find_or_create_by_email(:email => "bob@example.com",
  :lender => lender,
  :first_name => "Bob",
  :last_name => "Flemming",
  :password => "password",
  :password_confirmation => "password"
  )

puts 'Sign-in as:'
puts "  email: #{user.email}"
puts '  password: password'
