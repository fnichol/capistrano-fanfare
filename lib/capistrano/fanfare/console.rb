require 'capistrano'

module Capistrano::Fanfare::Console
  def self.load_into(configuration)
    configuration.load do
      def _cset(name, *args, &block)
        unless exists?(name)
          set(name, *args, &block)
        end
      end

      on :load do
        if find_task("foreman:start")
          _cset :console_env_cmd, "foreman run"
        elsif find_task("bundle:install")
          _cset :console_env_cmd, "bundle exec"
        end
      end


      # =========================================================================
      # These are the tasks that are available to help with deploying web apps.
      # You can have cap give you a summary of them with `cap -T'.
      # =========================================================================

      ##
      # Gratiously found in the moonshine codebase and iterated on:
      # https://github.com/railsmachine/moonshine

      desc <<-DESC
        Runs a rails/rack console on the first application server.
      DESC
      task :console, :roles => :app, :except => {:no_symlink => true} do
        rack_env = fetch(:rails_env, nil) || fetch(:rack_env, nil) || "production"
        env_cmd = fetch(:console_env_cmd, "")
        input = ''

        console_test = [
          "if [ -f #{current_path}/script/console ] ; then echo rails2",
          "; elif [ -f #{current_path}/script/console ] ; then echo rails3",
          "; elif [ -f #{current_path}/config.ru -a -f #{current_path}/Gemfile ]",
            "&& grep #{current_path}/Gemfile 'gem.*racksh' >/dev/null",
            "; then echo racksh",
          "; else echo unknown ; fi"
        ].join(' ')

        case capture(console_test).strip
        when "rails2"
          command = "cd #{current_path} && #{env_cmd} ./script/console #{rack_env}"
          prompt = /^(>|\?)>/
        when "rails3"
          command = "cd #{current_path} && #{env_cmd} rails console #{rack_env}"
          prompt = /:\d{3}:\d+(\*|>)/
        when "racksh"
          command = "cd #{current_path} && #{env_cmd} racksh #{rack_env}"
          prompt = /:\d{3}:\d+(\*|>)/
        else
          raise "A suitable rails/rack console could not be found."
        end

        run command do |channel, stream, data|
          next if data.chomp == input.chomp || data.chomp == ''
          print data
          channel.send_data(input = $stdin.gets) if data =~ prompt
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Console.load_into(Capistrano::Configuration.instance)
end
