source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-document_requests.gemspec
gemspec

if ar_version = ENV['AR']
  gem 'actionpack', ar_version
else
  gem 'actionpack', github: 'rails/rails'
end
