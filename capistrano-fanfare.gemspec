# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano/fanfare/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = %q{Capistrano recipes (with full test suite) for fanfare application deployment framework}
  gem.summary       = %q{Capistrano recipes (with full test suite) for fanfare application deployment framework}
  gem.homepage      = "https://github.com/fnichol/capistrano-fanfare"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "capistrano-fanfare"
  gem.require_paths = ["lib"]
  gem.version       = Capistrano::Fanfare::VERSION

  gem.add_dependency "capistrano", "~> 2.11.1"
  gem.add_dependency "capistrano_colors", "~> 0.5"
  gem.add_dependency "sushi", "~> 0.0.2"
  gem.add_dependency "multi_json", "~> 1.0"

  gem.add_development_dependency "minitest", "~> 2.11.2"
  gem.add_development_dependency "minitest-capistrano", "~> 0.0"
  gem.add_development_dependency "timecop", "~> 0.3"
  gem.add_development_dependency "mocha", "~> 0.10.5"
  gem.add_development_dependency "webmock", "~> 1.8.5"
end
