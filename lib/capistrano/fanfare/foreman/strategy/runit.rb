require 'capistrano/fanfare/foreman/strategy/base'

module Capistrano
  module Fanfare
    module Foreman
      module Strategy

        ##
        # Implements the runit Foreman export strategy.

        class Runit < Base
          def export
            svp = configuration[:runit_sv_path]

            run [
              "set -x &&",
              "svp=#{svp} &&",
              "cd #{configuration[:current_release]} &&",
              "if [ -f Procfile ] ; then",
                # create an empty staging directory for services
                "rm -rf ${svp}-pre &&",
                "mkdir -p ${svp}-pre &&",

                # export services into a *-pre directory
                "#{configuration[:foreman_cmd]} export runit",
                  "${svp}-pre",
                  "--app=#{configuration[:runit_app_name]}",
                  "--log=#{configuration[:shared_path]}/log",
                  "--user=#{configuration[:user]} &&",

                # fix any path references in files back to :runit_sv_path
                # and ensure that a non-zero sed exit doesn't propagate
                "set +x &&",
                "egrep -lr ${svp}-pre ${svp}-pre | (xargs",
                  "sed -i \"s|${svp}-pre|${svp}|g\" || true) &&",

                # calculate checksums of all service files in both
                # service directories
                "(cd ${svp} ; find . -path '*/supervise' -type d",
                  "-prune -o -type f | grep -v 'supervise$' | sort |",
                  "xargs openssl sha) > /tmp/sv-dir-$$ &&",
                "(cd ${svp}-pre ; find . -path '*/supervise' -type d",
                  "-prune -o -type f | grep -v 'supervise$' | sort |",
                  "xargs openssl sha) > /tmp/sv-pre-dir-$$ &&",
                "set -x &&",

                "if diff -q /tmp/sv-dir-$$ /tmp/sv-pre-dir-$$ >/dev/null ; then",
                  "echo '\\n===> Foreman export atrifacts are identical\\n' &&",
                  "rm -rf ${svp}-pre",

                "; else", # diff -q
                  "echo '\\n===> Updated Foreman export artifacts detected\\n' &&",
                  "echo '---> Stoping processes' &&",
                  "rm -f #{all_services} &&",
                  "echo '---> Installing updated Foreman export artifacts' &&",
                  "rm -rf ${svp} && mv ${svp}-pre ${svp} &&",
                  "touch ${svp}/.symlink_boot",
                "; fi &&", # diff -q

                # clean checksum calculations
                "echo '---> Cleaning up' &&",
                "rm -f /tmp/sv-{dir,pre-dir}-$$",

              "; else", # -f Procfile
                # die with a warning about including a Procfile
                "echo '>>>> A Procfile must exist in this project.' && exit 10",
              "; fi" # -f Procfile
            ].join(' ')
          end

          def register
            symlink_boot = capture([
              "if [ -f #{configuration[:runit_sv_path]}/.symlink_boot ] ; then",
                "echo true",
              "; else",
                "echo false",
              "; fi"
            ].join(' ')).chomp

            # if the service symlinks are fresh, this will start the
            # service automatically so we won't try to pile on and
            # call foreman:start or foreman:restart
            if symlink_boot == "true" && callbacks[:after]
              callbacks[:after].reject! { |c| c.source == "foreman:start" }
              callbacks[:after].reject! { |c| c.source == "foreman:restart" }
            end

            run [
              "ln -snf #{configuration[:runit_sv_path]}/*",
              "#{configuration[:runit_service_path]}/ &&",
              "rm -f #{configuration[:runit_sv_path]}/.symlink_boot"
            ].join(' ')
          end

          def start(proc_group = nil)
            run [
              "sv start #{all_services}",
              "(s=$? && echo \"Start exited with $s\" && exit $s)"
            ].join(' || ')
          end

          def stop(proc_group = nil)
            run [
              "sv stop #{all_services}",
              "(s=$? && echo \"Stop exited with $s\" && exit $s)"
            ].join(' || ')
          end

          def restart(proc_group = nil)
            run [
              "sv restart #{all_services}",
              "(s=$? && echo \"Restart exited with $s\" && exit $s)"
            ].join(' || ')
          end

          def ps
            run [
              "sv status #{all_services}",
              "(s=$? && echo \"Status exited with $s\" && exit $s)"
            ].join(' || ')
          end

          private

          def all_services
            [ configuration[:runit_service_path],
              "#{configuration[:runit_app_name]}-*"
            ].join('/')
          end
        end
      end
    end
  end
end
