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
              "cd #{configuration[:current_release]} &&",
              "if [ -f Procfile ] ; then",
                # create an empty staging directory for services
                "rm -rf #{svp}-pre &&",
                "mkdir -p #{svp}-pre &&",

                # export services into a *-pre directory
                "#{configuration[:foreman_cmd]} export runit",
                  "#{svp}-pre",
                  "--app=#{configuration[:runit_app_name]}",
                  "--log=#{configuration[:shared_path]}/log",
                  "--user=#{configuration[:user]} &&",

                # fix any path references in files back to :runit_sv_path
                # and ensure that a non-zero sed exit doesn't propagate
                "set +x &&",
                "egrep -lr #{svp}-pre #{svp}-pre | (xargs",
                  "sed -i 's|#{svp}-pre|#{svp}|g' || true) &&",

                # calculate checksums of all service files in both
                # service directories
                "(cd #{svp} ; find . -path '*/supervise' -type d",
                  "-prune -o -type f | grep -v 'supervise$' | sort |",
                  "xargs openssl sha) > /tmp/sv-dir-$$ &&",
                "(cd #{svp}-pre ; find . -path '*/supervise' -type d",
                  "-prune -o -type f | grep -v 'supervise$' | sort |",
                  "xargs openssl sha) > /tmp/sv-pre-dir-$$ &&",
                "set -x &&",

                "if diff -q /tmp/sv-dir-$$ /tmp/sv-pre-dir-$$ >/dev/null ; then",
                  "echo '\\n---> Foreman export atrifacts are identical\\n' &&",
                  "rm -rf #{svp}-pre",

                "; else", # diff -q
                  "echo '\\n---> Installing updated Foreman export artifacts\\n' &&",
                  "rm -rf #{svp} && mv #{svp}-pre #{svp}",
                "; fi &&", # diff -q

                # clean checksum calculations
                "rm -f /tmp/sv-{dir,pre-dir}-$$",

              "; else", # -f Procfile
                # die with a warning about including a Procfile
                "echo '>>>> A Procfile must exist in this project.' && exit 10",
              "; fi" # -f Procfile
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
