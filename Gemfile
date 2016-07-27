# frozen_string_literal: true

# Set Ruby version based on .ruby-version if it exists
ruby_version_file = '.ruby-version'
ruby_version = if File.exist?(ruby_version_file)
                 File.read(ruby_version_file).match(/(\d+\.\d+\.\d+)/)
               end
ruby ruby_version.to_s unless ruby_version.nil?

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

## Custom

# Markdown parser
gem 'kramdown', '~> 1.11', '>= 1.11.1'

# Sanitize HTML, used when sending emails
gem 'sanitize', '~> 4.1'

# Twitter Bootstrap
gem 'bootstrap', '~> 4.0.0.alpha3'

# Use Twitter Bootsrap for forms
gem 'bootstrap_form', '~> 2.4'

# Install Font Awesome icons
gem 'font-awesome-sass', '~> 4.6', '>= 4.6.2'

# Faraday is used to create an API client for JIRA
gem 'faraday', '~> 0.9.2'

# Faraday middleware provides a JSON parser for Faraday
gem 'faraday_middleware', '~> 0.10.0'

# Support Authentication
gem 'omniauth', '~> 1.3', '>= 1.3.1'

# Support SAML with OmniAuth
gem 'omniauth-saml', '~> 1.6'

# Support Google Auth with OmniAuth
gem 'omniauth-google-oauth2', '~> 0.4.1'

# Validate email address format
gem 'rfc822', '~> 0.1.5'

# Use the Rubocop linter
gem 'rubocop', '~> 0.42.0', require: false
