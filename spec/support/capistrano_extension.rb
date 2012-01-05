# Taken from the awesome capistrano-spec gem
# (https://github.com/technicalpickles/capistrano-spec)
module Capistrano
  module Spec
    module ConfigurationExtension
      def get(remote_path, path, options={}, &block)
        gets[remote_path] = {:path => path, :options => options, :block => block}
      end

      def gets
        @gets ||= {}
      end

      def run(cmd, options={}, &block)
        runs[cmd] = {:options => options, :block => block}
      end

      def runs
        @runs ||= {}
      end

      def upload(from, to, options={}, &block)
        uploads[from] = {:to => to, :options => options, :block => block}
      end

      def uploads
        @uploads ||= {}
      end
    end
  end
end
