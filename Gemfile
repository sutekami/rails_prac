source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'aws-sdk-s3'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'coffee-rails', '~> 4.2'
gem 'delayed_job_active_record'
gem 'jbuilder', '~> 2.5'
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
gem 'puma', '~> 4.3'
gem 'rails'
gem 'rmagick'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'fuubar'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'brakeman', require: false
  gem 'listen'
  gem 'rbs', require: false
  gem 'rbs_rails', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'steep', require: false
  gem 'web-console', '>= 3.3.0'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
