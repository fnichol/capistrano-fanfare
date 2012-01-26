# Capistrano::Fanfare [![Build Status](https://secure.travis-ci.org/fnichol/capistrano-fanfare.png)](http://travis-ci.org/fnichol/capistrano-fanfare)

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-fanfare'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-fanfare

## Usage

TODO: Write usage instructions here

Create a `Capfile` that looks like:

    load 'deploy'

    require 'capistrano/fanfare'

    fanfare_recipe 'defaults'
    fanfare_recipe 'multistage'
    fanfare_recipe 'git_style'
    fanfare_recipe 'bundler'
    fanfare_recipe 'assets'
    fanfare_recipe 'db_seed'

    fanfare_recipe 'foreman'
    fanfare_recipe 'database_yaml'

    fanfare_recipe 'colors'
    fanfare_recipe 'ssh'
    fanfare_recipe 'console'
    fanfare_recipe 'campfire'
    fanfare_recipe 'airbrake'

    Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

    load 'config/deploy'

Pick and choose your fanfare recipes in `Capfile`--they are designed to work
independently but also build off each other.

Create a `config/deploy.rb` that looks like:

    set :application, "myappname"
    set :repository,  "git@mygitserver.com:myappname.git"

    set :campfire_options,  :account => 'cfireaccount',
                            :room => 'Dev room',
                            :token => '010010010100101',
                            :ssl => true

Create a `config/deploy/staging.rb` (assuming the *multistage* recipe) that
looks like:

    deploy_server = "myserver.example.com"

    role :web, deploy_server
    role :app, deploy_server
    role :db,  deploy_server, :primary => true
    role :db,  deploy_server

There are several optional recipes that need additional gems in your Gemfile:

    gem 'airbrake'

    group :development do
      gem 'capistrano-fanfare'
      gem 'capistrano-campfire'
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
