module Capistrano
  module Fanfare
    module Foreman
      module Strategy

        ##
        # This class defines the abstract interface for all Capistrano
        # foreman deployment strategies. Subclasses must implement at least the
        # #export, #start, and #stop methods.

        class Base
          attr_reader :configuration

          def initialize(config = {})
            @configuration = config
          end

          def export
            raise NotImplementedError, "`export' is not implemented by #{self.class.name}"
          end

          def start(proc_group = nil)
            raise NotImplementedError, "`start' is not implemented by #{self.class.name}"
          end

          def stop(proc_group = nil)
            raise NotImplementedError, "`stop' is not implemented by #{self.class.name}"
          end

          def register
            # no-op
          end

          def restart(proc_group = nil)
            stop(proc_group)
            start(proc_group)
          end

          protected

          # This is to allow helper methods like "run" and "put" to be more
          # easily accessible to strategy implementations.
          def method_missing(sym, *args, &block)
            if configuration.respond_to?(sym)
              configuration.send(sym, *args, &block)
            else
              super
            end
          end
        end
      end
    end
  end
end
