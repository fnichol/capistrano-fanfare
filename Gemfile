source 'https://rubygems.org'

# Specify your gem's dependencies in capistrano-fanfare.gemspec
gemspec

group :test do
  gem 'rake', '~> 0.9'
  gem 'foreman', '>= 0.48.0'
  gem 'campy'
  gem 'airbrake'

  gem 'growl'
  gem 'guard'
  gem 'guard-minitest'
end

platforms :jruby do
  gem 'jruby-openssl'
end
