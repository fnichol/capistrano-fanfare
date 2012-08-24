require 'capistrano'
require 'tempfile'

module Capistrano::Fanfare::Log
  def self.load_into(configuration)
    configuration.load do
      set :tail_cmd, "tail"

      def resolve_logfile
        rack_env = fetch(:rails_env, nil) || fetch(:rack_env, nil) || "production"

        File.join(current_path, "log", "#{rack_env}.log")
      end

      def resolve_editor
        ENV['editor'] || ENV['EDITOR'] || ENV['VISUAL'] || "vi"
      end

      def log_exec(cmd)
        exec cmd
      end

      # =========================================================================
      # These are the tasks that are available to help with deploying web apps.
      # You can have cap give you a summary of them with `cap -T'.
      # =========================================================================

      namespace :log do
        desc <<-DESC
          Tails the deployed application log.You can set the rails \
          environment by setting the :rails_env variable. The defaults are:

              set :rails_env, "production"
              set :tail_cmd,  "tail"
        DESC
        task :tail, :role => :app, :except => { :no_release => true } do
          stream("#{tail_cmd} -f #{resolve_logfile}")
        end

        desc <<-DESC
          View log files in local editor. You can set the rails environment \
          and tail command by setting variables. The defaults are:

              set :rails_env, "production"
              set :tail,      "tail"

          To override the default number of lines (500), you can pass in \
          the `n' environment variable like so:

              $ cap log:view n=900

          To override your EDITOR/VISUAL environment settings for your visual \
          editor, you can pass in the `editor' environment variable like so:

              $ cap log:view editor=nano

          Otherwise this task will try to resolve your editor in the \
          following order:

              1) use the `editor' environment override variable value
              2) use the `EDITOR' shell environment variable value
              3) use the `VISUAL' shell environment variable value
              4) use `vi' which should be in almost any PATH
        DESC
        task :view, :role => :app, :except => { :no_release => true } do
          line_nums = ENV["n"] || 500
          cmd       = "#{tail_cmd} -n #{line_nums} #{resolve_logfile}"
          logs      = Hash.new { |h,k| h[k] = '' }

          run(cmd) do |channel, stream, data|
            logs[channel[:host]] << data
            break if stream == :err
          end

          tmpfile = Tempfile.open('w')
          logs.each do |host, log|
            tmpfile.write("--- #{host} ---\n\n")
            tmpfile.write(log + "\n")
          end
          tmpfile.flush
          tmpfile.close

          log_exec "#{resolve_editor} #{tmpfile.path}"
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Log.load_into(Capistrano::Configuration.instance)
end
