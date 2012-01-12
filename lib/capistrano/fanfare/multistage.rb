require 'capistrano'

module Capistrano::Fanfare::Multistage
  def self.load_into(configuration)
    configuration.load do
      def _cset(name, *args, &block)
        unless exists?(name)
          set(name, *args, &block)
        end
      end

      _cset :stages,          %w{staging production}
      _cset :default_stage,   "staging"

      require 'capistrano/ext/multistage'
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Multistage.load_into(Capistrano::Configuration.instance)
end
