require 'capistrano/fanfare/foreman/strategy/base'

module Capistrano
  module Fanfare
    module Foreman
      module Strategy
        class Runit < Base
          def export
            run [
              "cd #{configuration[:current_release]} &&",
              "if [ -f Procfile ] ; then",
              "mkdir -p #{configuration[:runit_sv_path]} &&",
              "#{configuration[:foreman_cmd]} export runit",
              "#{configuration[:runit_sv_path]}",
              "--app=#{configuration[:runit_app_name]}",
              "--log=#{configuration[:shared_path]}/log",
              "--user=#{configuration[:user]} &&",
              "find #{configuration[:runit_sv_path]} -type f -name run",
              "-exec chmod 755 {} \\; ; else",
              "echo '>>>> A Procfile must exist in this project.' && exit 10 ;",
              "fi"
            ].join(' ')
          end

          def register
            run [
              "ln -snf #{configuration[:runit_sv_path]}/*",
              "#{configuration[:runit_service_path]}/"
            ].join(' ')
          end

          def start(proc_group = nil)
            run [
              "sv start #{configuration[:runit_service_path]}/",
              "#{configuration[:runit_app_name]}-*"
            ].join
          end

          def stop(proc_group = nil)
            run [
              "sv stop #{configuration[:runit_service_path]}/",
              "#{configuration[:runit_app_name]}-*"
            ].join
          end

          def restart(proc_group = nil)
            run [
              "sv restart #{configuration[:runit_service_path]}/",
              "#{configuration[:runit_app_name]}-*"
            ].join
          end

          def ps
            run [
              "sv status #{configuration[:runit_service_path]}/",
              "#{configuration[:runit_app_name]}-*"
            ].join
          end
        end
      end
    end
  end
end
