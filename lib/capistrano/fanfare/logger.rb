require 'capistrano'

module Capistrano::Fanfare::Logger
  def self.load_into(configuration)
    configuration.load do
      self.logger.instance_eval do
        def log(level, message, line_prefix=nil)
          if level <= self.level
            (RUBY_VERSION >= "1.9" ? message.lines : message).each do |line|
              if line_prefix
                if line_prefix.to_s =~ /out :: / && line.strip =~ /^\-\-\-\-\-> /
                  device.puts "#{line.strip} (#{line_prefix.to_s.sub(/out :: /, '')})\n"
                else
                  device.puts "       [#{line_prefix.to_s.sub(/out :: /, '')}] #{line.strip}\n"
                end
              else
                case line.strip
                when /^(executing|Running command) `.*'$/, /^transaction: /
                  device.puts "-----> #{line.strip.sub(/^executing /, 'task ')}\n"
                when /^executing ".*"$/
                  if self.level >= 3
                    device.puts "       #{line.strip.sub(/^executing /, 'run ')}\n"
                  end
                else
                  # device.puts "#{indent} #{line.strip}\n"
                  if level <= 2
                    device.puts "-----> #{line.strip}\n"
                  else
                    device.puts "       #{line.strip}\n"
                  end
                end
              end
            end
          end
        end
      end

      if ARGV.select { |a| a =~ /^\-v/ }.empty?
        self.logger.info "Setting default log level to INFO."
        self.logger.level = 2
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Logger.load_into(Capistrano::Configuration.instance)
end
