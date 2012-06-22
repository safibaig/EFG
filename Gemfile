source 'https://rubygems.org'

gem 'rails', '~> 3.1.1'

platforms :jruby do
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-mysql'
end

platforms :ruby do
 gem 'mysql2'
end

gem 'devise'
gem 'haddock'
gem 'jquery-rails', "~> 1.0.19"
gem 'money'
gem 'simple_form'
gem 'twitter-bootstrap-rails', :git => "git://github.com/seyhunak/twitter-bootstrap-rails.git", :branch => "static"
gem 'activerecord-import'
gem "builder"
gem "bourbon"
gem 'will_paginate'
gem 'bootstrap-will_paginate'

group :passenger_compatibility do
  gem 'rake', '0.9.2'
end

group :assets do
  gem 'sass-rails', '3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'

  platforms :jruby do
    # Need to use Rhino rather than V8
    gem 'therubyrhino'
  end

#  platforms :ruby do
#    # Fine to use V8
#    gem 'therubyracer'
#  end
end

group :development do
  gem 'guard-rspec'
end

group :import do
  gem "faker"
end

group :development, :test do
  gem 'rspec-rails'
  gem 'ci_reporter'
  gem 'simplecov-rcov'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
end
