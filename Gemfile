source 'https://rubygems.org'

gem 'rails', '~> 3.1.1'
gem 'mysql2'

gem 'canable'
gem 'devise'
gem 'haddock'
gem 'jquery-rails', "~> 1.0.19"
gem 'money'
gem 'simple_form'
gem 'twitter-bootstrap-rails'
gem 'activerecord-import'
gem "builder"
gem "bourbon"
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'prawn'
gem 'progressbar'

gem 'exception_notification'
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'lograge'
gem 'unicorn'

group :passenger_compatibility do
  gem 'rake', '0.9.2'
end

group :assets do
  gem 'sass-rails', '3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
end

group :development do
  gem 'guard-rspec'
  gem 'powder'
end

group :import do
  gem "faker"
end

group :development, :test do
  gem 'rspec-rails'
  gem 'ci_reporter'
  gem 'simplecov-rcov'
  gem 'debugger'
  gem 'puma'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'pdf-reader'
end
