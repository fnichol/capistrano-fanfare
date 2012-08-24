# <a name="title"></a> Capistrano::Fanfare [![Build Status](https://secure.travis-ci.org/fnichol/capistrano-fanfare.png)](http://travis-ci.org/fnichol/capistrano-fanfare) [![Dependency Status](https://gemnasium.com/fnichol/capistrano-fanfare.png)](https://gemnasium.com/fnichol/capistrano-fanfare) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/fnichol/capistrano-fanfare)

**Notice:** This README is under active development.

## <a name="features"></a> Features

Coming soon...

## <a name="installation"></a> Installation

Add this line to your application's Gemfile:

    gem 'capistrano-fanfare'

And then execute:

    $ bundle

## <a name="usage"></a> Usage

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

    fanfare_recipe 'info'
    fanfare_recipe 'colors'
    fanfare_recipe 'ssh'
    fanfare_recipe 'console'
    fanfare_recipe 'log'
    fanfare_recipe 'campfire'
    fanfare_recipe 'airbrake'

    Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

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
      gem 'campy'
    end

## <a name="recipes"></a> Recipes

**Foundational**

* [git_style](#recipes-git-style):
  GitHub-style deployments, fully compatible with third party recipes.
* [foreman](#recipes-foreman):
  Forget Unicorns, Resque workers, and God. Think processes.
* [bundler](#recipes-bundler):
  Binstub `PATH`-aware deployments with custom shebangs and more.

**Core**

* [defaults](#recipes-defatuls):
  Common baseline defaults and an augmented `deploy:cold`.
* [multistage](#recipes-multistage):
  Deploy to multiple environments like `"staging"` and `"production"`.
* [assets](#recipes-assets):
  Rails asset pipeline support: done!
* [database_yaml](#recipes-database-yaml):
  No more database password baked in your code, leave that up to the server.
* [db_seed](#recipes-db-seed):
  Seeding your Rails database, autowired into `deploy:cold`.

**Gravy**

* [ssh](#recipes-ssh):
  Connect to your infrastructure nodes without thinking.
* [console](#recipes-console):
  Rails 2/3, Sinatra, and Rack consoles, running in one command.
* [log](#recipes-log):
  Ability to tail logs and load logs into a local editor.
* [colors](#recipes-colors):
  Deploys, but prettier.
* [campfire](#recipes-campfire):
  Notify your team of deployment and maintenace events.
* [airbrake](#recipes-airbrake):
  Track your deployments in Airbrake/Hoptoad/Errbit
* [info](#recipes-info):
  Deployment configuration information, available at a glance.

### <a name="recipes-foundational"></a> Foundational

#### <a name="recipes-git-style"></a> git_style

> GitHub-style deployments, fully compatible with third party recipes.

A Git style deployment strategy based on GitHub's
[Deployment Script Spring Cleaning][github_spring] blog post.

#### <a name="recipes-foreman"></a> foreman

> Forget Unicorns, Resque workers, and God. Think processes.

#### <a name="recipes-bundler"></a> bundler

> Binstub `PATH`-aware deployments with custom shebangs and more.

Uses the delivered [Bundler][cap_bundler] implementation with support for
shebangs, binstubs `PATH` inclusion, and a generated `bin/bundle` binstub
script file.

### <a name="recipes-core"></a> Core

#### <a name="recipes-defaults"></a> defaults

> Common baseline defaults and an augmented `deploy:cold`.

#### <a name="recipes-multistage"></a> multistage

> Deploy to multiple environments like `"staging"` and `"production"`.

Uses the delivered [Capistrano multistage][cap_multistage] implementation with
a few additional helpers.

#### <a name="recipes-asssets"></a> assets

> Rails asset pipeline support: done!

#### <a name="recipes-db-seed"></a> db_seed

> Tracking deployments in Airbrake

#### <a name="recipes-database-yaml"></a> database_yaml

> No more database password baked in your code, leave that up to the server.

### <a name="recipes-gravy"></a> Gravy

#### <a name="recipes-ssh"></a> ssh

> Connect to your infrastructure nodes without thinking.

#### <a name="recipes-console"></a> console

> Rails 2/3, Sinatra, and Rack consoles, running in one command.

#### <a name="recipes-log"></a> log

> Ability to tail logs and load logs into a local editor.

#### <a name="recipes-colors"></a> colors

> Deploys, but prettier.

> Rails console, ready for input in one command.

#### <a name="recipes-campfire"></a> campfire

> Notify your team of deployment and maintenace events.

#### <a name="recipes-airbrake"></a> airbrake

> Track your deployments in Airbrake/Hoptoad/Errbit

#### <a name="recipes-info"></a> info

> Deployment configuration, available at a glance.

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Fletcher Nichol][fnichol] (<fnichol@nichol.ca>)

## <a name="license"></a> License

MIT (see [LICENSE][license])

[defaults_src]:       https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/defaults.rb
[multistage_src]:     https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/multistage.rb
[git_style_src]:      https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/git_style.rb
[bundler_src]:        https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/bundler.rb
[assets_src]:         https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/assets.rb
[db_seed_src]:        https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/db_seed.rb
[foreman_src]:        https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/foreman.rb
[database_yaml_src]:  https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/database_yaml.rb
[info_src]:           https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/info.rb
[colors_src]:         https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/colors.rb
[ssh_src]:            https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/ssh.rb
[console_src]:        https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/console.rb
[campfire_src]:       https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/campfire.rb
[airbrake_src]:       https://github.com/fnichol/capistrano-fanfare/blob/master/lib/capistrano/fanfare/airbrake.rb

[cap_assets]:     https://github.com/capistrano/capistrano/blob/master/lib/capistrano/recipes/deploy/assets.rb
[cap_bundler]:    https://github.com/carlhuda/bundler/blob/master/lib/bundler/capistrano.rb
[cap_multistage]: https://github.com/capistrano/capistrano/blob/master/lib/capistrano/ext/multistage.rb
[github_spring]:  https://github.com/blog/470-deployment-script-spring-cleaning
[license]:        https://github.com/fnichol/capistrano-fanfare/blob/master/LICENSE

[fnichol]:      https://github.com/fnichol
[repo]:         https://github.com/fnichol/capistrano-fanfare
[issues]:       https://github.com/fnichol/capistrano-fanfare/issues
[contributors]: https://github.com/fnichol/capistrano-fanfare/contributors
