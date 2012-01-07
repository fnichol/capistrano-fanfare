require 'capistrano/recipes/deploy/strategy/remote'

module Capistrano
  module Deploy
    module Strategy

      class GitStyle < Remote
        protected

        def command
          @command ||= "if [ -d #{configuration[:current_path]}/.git ]; then " +
            "#{source.sync(revision, configuration[:current_path])}; " +
            "else #{source.checkout(revision, configuration[:current_path])}; fi"
        end

        def mark
          "(mkdir -p #{configuration[:release_path]})"
        end
      end
    end
  end
end
