lender = Lender.find_or_create_by_name('Banksy')

user = User.find_by_email('bob@example.com')

if !user
  user = User.new
  user.lender = lender
  user.first_name = 'Bob'
  user.last_name = 'Flemming'
  user.email = 'bob@example.com'
  user.password = user.password_confirmation = 'password'
  user.save!
end

puts 'Sign-in as:'
puts "  email: #{user.email}"
puts '  password: password'
