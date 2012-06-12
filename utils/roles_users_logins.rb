require 'csv'
require 'time'

users = CSV.read('SFLG_USER_DATA_TABLE.csv', headers: true)
roles_users = CSV.read('SFLG_USER_ROLE_DATA_TABLE.csv', headers: true)

user_lookup = users.inject({}) { |memo, user|
  memo[user['USER_ID']] = user
  memo
}

puts ['Role', 'Number of Users', 'Last login'].map(&:inspect).join(',')

roles_users.group_by { |ru|
  ru['ROLE']
}.sort_by { |a|
  a[0]
}.each { |a|
  role = a[0]
  number_of_users = a[1].length
  max_login = a[1].map { |ru|
    user_lookup[ru['USER_ID']]['LAST_LOGIN_TIME']
  }.compact.map { |s| Date.parse(s) }.max

  puts [
    role,
    number_of_users,
    max_login ? max_login.strftime('%-d %b, %Y') : ''
  ].map(&:inspect).join(',')
}
