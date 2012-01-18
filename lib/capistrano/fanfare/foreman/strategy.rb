module Capistrano
  module Fanfare
    module Foreman
      module Strategy

        ##
        # Returns a new instance of the +strategy+ Foreman export strategy,
        # which has been injected with the Capistrano::Configuration instance.

        def self.new(strategy, config={})
          strategy_file = "capistrano/fanfare/foreman/strategy/#{strategy}"
          require(strategy_file)

          strategy_const = strategy.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
          if const_defined?(strategy_const)
            const_get(strategy_const).new(config)
          else
            raise Capistrano::Error, "could not find `#{name}::#{strategy_const}' in `#{strategy_file}'"
          end
        rescue LoadError
          raise Capistrano::Error, "could not find any strategy named `#{strategy}'"
        end
      end
    end
  end
end
