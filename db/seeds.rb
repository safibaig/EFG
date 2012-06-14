lender = Lender.new
lender.name = 'Banksy'
lender.save!

user = User.new
user.lender = lender
user.first_name = 'Bob'
user.last_name = 'Flemming'
user.email = 'bob@example.com'
user.password = user.password_confirmation = 'password'
user.save!

puts 'Sign-in as:'
puts "  email: #{user.email}"
puts '  password: password'
