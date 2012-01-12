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

      # =========================================================================
      # These are the tasks that are available to help with deploying web apps,
      # and specifically, Rails applications. You can have cap give you a summary
      # of them with `cap -T'.
      # =========================================================================

      desc <<-DESC
        Lists all valid deployment environments.
      DESC
      task :all_stages, :roles => :app, :except => { :no_release => true } do
        logger.important "Valid stages are:\n\n"
        fetch(:stages, []).each { |s| logger.important "* #{s}" }
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Multistage.load_into(Capistrano::Configuration.instance)
end
