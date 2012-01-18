require 'capistrano/recipes/deploy/strategy/remote'

module Capistrano
  module Deploy
    module Strategy

      ##
      # Implements a Git style deployment strategy largely propsed and
      # introduced by Chris Wanstrath in a GitHub blog post entitiled
      # "Deployment Script Spring Cleaning"
      # (source: https://github.com/blog/470-deployment-script-spring-cleaning).
      #
      # All fresh checkouts and updates happen in the :current_path directory
      # and the :releases_path directories get used for deployment history
      # tracking (useful for rollbacks).

      class GitStyle < Remote
        protected

        ##
        # Performs a `git checkout` if :current_path does not exist and a
        # `git fetch && git reset --hard` for updates.

        def command
          @command ||= "if [ -d #{configuration[:current_path]}/.git ]; then " +
            "#{source.sync(revision, configuration[:current_path])}; " +
            "else #{source.checkout(revision, configuration[:current_path])}; fi"
        end

        ##
        # Creates a stub directory representing the current release to be
        # deployed with the form "20120101020304-18c322b65". The date is
        # calculated similar to the default capistrano deploy recipe but
        # the full Git SHA commit hash is appended which will be used to
        # determine the last revision that was deployed.

        def mark
          "(mkdir -p #{File.join(configuration[:releases_path], configuration[:release_name])})"
        end
      end
    end
  end
end
