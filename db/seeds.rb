lender = Lender.find_or_create_by_name("Banksy")
lender.save!

user = LenderUser.find_or_create_by_email(email: "bob@example.com",
  first_name: "Bob",
  last_name: "Flemming",
  password: "password",
  password_confirmation: "password"
  )

user.lender = lender
user.save!

puts 'Sign-in as:'
puts "  email: #{user.email}"
puts '  password: password'
