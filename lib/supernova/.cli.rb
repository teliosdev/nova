require 'optparse'

module Supernova
  # Handles the Command Line Interface for supernova, such as setting
  # up options, loading stars, and others.
  class CLI

    LOADING_PATHS = ["./galaxy/**/*", Dir.home + "/.galaxy/**/*", "/etc/galaxy/**/*",
      File.absolute_path("../../../galaxy/**/*", __FILE__)]

    def self.parse(args)
      options = { :load_paths => LOADING_PATHS.dup, :remote_opts => {},
        :remote => Supernova::Remote::Local, :severity => Logger::WARN,
        :command => nil, :command_opts => {}, :event_opts => {} }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: supernova [options]"
        opts.separator ""
        opts.separator "options:"

        opts.on("-I", "--include PATH",
          "Adds PATH to the loading paths for galaxies.") do |path|
          options[:load_paths] << path
        end

        opts.on("-R", "--remote REMOTE",
          "Uses the given remote.") do |remote|
          options[:remote] = Supernova::Remote.const_get remote.gsub(/\A[a-z]/) { |m|
            m.upcase }.gsub(/\_[a-z]/) { |m| m[2].upcase }
        end

        opts.on("-r NAME=VALUE", "--remote-opt NAME=VALUE",
          "Sets the option for the remote.") do |data|
          split = data.split('=')
          options[:remote_opts][split.shift.to_sym] = split.join('=')
        end

        opts.on("-c", "--command COMMAND",
          "Runs the given command.  Should be in the format [<star type>.]<star name>:<action>") do |cmd|
            options[:command] = cmd
        end

        opts.on("-C NAME=VALUE", "--command-opt NAME=VALUE",
          "Sets the option for the command.") do |data|
          split = data.split('=')
          options[:command_opts][split.shift.to_sym] = split.join('=')
        end

        opts.on("-e NAME=VALUE", "--event-opt NAME=VALUE",
          "Sets the option for the event.") do |data|
          split = data.split('=')
          options[:event_opts][split.shift.to_sym] = split.join('=')
        end

        opts.on("-l", "--log SEVERITY",
          "Sets the logging severity.  Defaults to WARN.") do |sev|
          options[:severity] = Logger.const_get sev.upcase
        end

        opts.on("-h", "--help", "Show this message.") do
          puts opts
          exit
        end

        opts.on("-v", "--version", "Show the version of Supernova.") do
          puts Supernova::VERSION
          exit
        end

      end

      parser.parse!(args)

      options
    end

    # Initialize the CLI with the given options.
    #
    # @param options [Hash<Symbol, Object>] the options for the CLI.
    # @option options [Array<String>] :load_paths the paths to check
    #   for for stars.  All files in these paths will be loaded as a
    #   star, reguardless of the file extension.
    # @option options [Hash] :remote_opts the options for the remote.
    # @option options [Module] :remote the remote to use for managing
    #   the system.
    # @option options [Integer] :severity the severity to use when
    #   logging.
    def initialize(options)
      @options = options

      Supernova.logger.level = @options[:severity]
    end

    def run
      load_files

      if @options[:command]
        handle_command
      end
    end

    def handle_command
      load_files
      klass, action = resolve_command @options[:command]

      if klass && action
        Supernova.logger.debug { "Running event #{action} from class #{klass}" }
        pass_to = @options[:command_opts]
        pass_to[:remote] = @options[:remote_opts]
        inst = klass.new(@options[:remote])
        inst.options = pass_to
        inst.run!(action.intern, @options[:event_opts])
      else
        raise StandardError, "Could not resolve command #{@options[:command]}"
      end
    end

    # Loads the files in the given paths.  Globs the paths, then loads
    # the files matching the globs.
    #
    # @return [void]
    def load_files
      @options[:load_paths].map do |path|
        Supernova.logger.debug(path)
        Dir[path].to_a
      end.flatten.map { |f| File.absolute_path(f) }.each do |f|
        next if File.directory?(f)
        Supernova.logger.debug { "Requiring file #{f}..." }
        require f
      end
    end

    private

    # Resolves the given command string to what it should be, as a
    # class.  Returns nil if it can't resolve it.
    #
    # @example
    #   resolve_command "Type.something:action" # => Type.something
    # @example
    #   resolve_command "something:action" # => Type.something
    # @param string [String] the command string to resolve.
    # @return [nil, Array<(Class, Symbol)>] the result of resolving.
    def resolve_command(string)
      major, minor, action = string.scan(/\A(?:(.+)\.)?(.+?)(?:\:(.+))?\z/).flatten
      [if major
        major = major.gsub(/([A-Z])/) { |a| "_#{a.downcase}" }.gsub("::", "/")[1..-1]
        Star[major.intern]
      else
        Star.stars.values.inject(&:merge)
      end[minor.intern], action]

    rescue
      [nil, nil]
    end

  end
end
