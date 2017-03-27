source 'https://rubygems.org'
ruby '2.4.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Postgresql as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Foundation for frontend framework
gem 'foundation-rails', '~> 6.2.3.0'
# For html templating
gem 'haml-rails', '~> 0.9.0'
# For managing web server Procfile
gem 'foreman', '~> 0.83.0'
# Config variables
gem 'yappconfig', '~> 0.3.1'
# for general API calls
gem 'rest-client', require: 'rest-client'
# Google's official Ruby client library for oauth2
gem 'googleauth', require: 'googleauth'
# Google Analytics API integration
gem 'google-api-client', '~> 0.9', require: 'google/apis/analyticsreporting_v4'
# Google AdWords API integration
gem 'google-adwords-api', require: 'adwords_api'
# For Twitter API integration
gem 'twitter-ads', '~> 1.0.0'
# Running background jobs with sidekiq
gem 'sidekiq', '~> 4.2.9'
# For tracking status of background jobs
gem 'sidekiq-status'
# For scheduling cron-like jobs
gem "sidekiq-cron", "~> 0.4.0"
# Sidekiq web for monitoring sidekiq processes
gem 'sinatra', github: 'sinatra/sinatra', require: false
# For storing CSV reports
gem 'paperclip', '5.1.0'
gem 'aws-sdk', '2.8.2'
# For error tracking
gem 'rollbar'
# For pagination
gem 'kaminari'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  # Autorun tests
  gem 'guard'
  gem 'guard-rspec'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  gem 'awesome_print'
end

group :test do
  # Running tests with RSpec and Capybara 
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl_rails', '~> 4.5.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
