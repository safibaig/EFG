source 'https://rubygems.org'

gem "bourbon", '2.1.1'
gem "builder", '3.0.0'
gem 'activerecord-import', '0.2.11'
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'bootstrap-will_paginate', '0.0.7'
gem 'canable', '0.3.0'
gem 'devise', '2.1.0'
gem "devise-encryptable", "0.1.1"
gem 'exception_notification', '2.5.2'
gem 'jquery-rails', "1.0.19"
gem 'lograge', '0.1.2'
gem 'money', '5.0.0'
gem 'mysql2', '0.3.11'
gem "parallel"
gem "parallel_tests"
gem 'plek'
gem 'prawn', '0.12.0'
gem 'progressbar', '0.11.0'
gem 'rack-ssl-enforcer'
gem 'rails', '3.2.9'
gem 'simple_form', '2.0.2'
gem 'statsd-ruby', '1.0.0'
gem 'twitter-bootstrap-rails', '2.0.7'
gem 'unicorn', '4.3.1'
gem 'useragent', '0.4.10'
gem 'weekdays', '1.0.2'
gem 'whenever', '0.7.3', :require => false
gem 'will_paginate', '3.0.3'

group :assets do
  gem 'sass-rails', '3.2.5'
  gem 'therubyracer', '0.10.1'
  gem 'uglifier', '1.2.4'
end

group :development do
  gem 'guard-rspec', '0.7.2'
  gem 'powder', '0.1.8'
end

group :development, :test do
  gem 'brakeman', '1.7.0'
  gem 'ci_reporter', '1.7.0'
  gem 'debugger', '1.1.4'
  gem 'rspec-rails', '2.10.1'
  gem 'simplecov-rcov', '0.2.3'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'factory_girl_rails', '3.3.0'
  gem 'launchy', '2.1.0'
  gem 'pdf-reader', '1.1.1'
  gem 'timecop'
end

group :extract do
  # gem "data-anonymization", :path => "../data-anonymization"
  gem "data-anonymization", :git => 'git://github.com/jabley/data-anonymization.git', :branch => 'mass-assignment'
  gem "sqlite3", "1.3.6"
end
