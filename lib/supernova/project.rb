require 'yaml'

module Supernova

  # A supernova project, containing the galaxy and configuration
  # settings for that project.
  class Project

    # The default paths to load from.
    DEFAULT_PATHS = [File.absolute_path("../../../galaxy", __FILE__)]

    # Whether or not the given directory is deemable as a supernova
    # project.
    #
    # @param dir [String] the directory to test.
    # @return [Boolean]
    def self.valid?(dir)
      Dir.new(dir).each.include?("supernova.yml")
    end

    # The directory the project is based in.
    #
    # @return [Directory]
    attr_reader :directory

    # The load paths for this project.
    #
    # @return [Array<String>]
    attr_reader :load_paths

    # The options that were loaded from the config for this project.
    #
    # @return [Hash]
    attr_reader :options

    # Initializes the project.  Loads the configuration file by
    # default.
    #
    # @param dir [String] the path to the directory for the project.
    # @param load_config [Boolean] whether or not to load the
    #   configuration file.
    def initialize(dir, load_config = true)
      @directory = Dir.new(dir)
      @load_paths = DEFAULT_PATHS.dup
      @options   = {}

      if load_config
        load_config!
      end
    end


    # Loads the configuration file.
    #
    # @return [Hash] the data.
    def load_config!
      return unless options.empty?

      data = ::YAML.load_file(File.open("#{directory.path}/supernova.yml", "r"))
      load_paths.push(*data.fetch("load_paths", []))

      load_paths.map! do |path|
        File.absolute_path(path, directory.path)
      end

      @options = data
    end

    # Requires all of the star files that is in the project.
    #
    # @return [void]
    def require_files
      @load_paths.each do |path|
        Dir["#{path}/**/*"].each do |f|
          require f
        end
      end
    end

    # Runs the servers defined in the options.
    #
    # @note If do_fork is false, only the first server in the config
    #   file will actually be created.
    # @param do_fork [Boolean] whether or not to actually fork the
    #   process when creating servers.
    # @param which [Array<String>] which servers to run.  Defaults to
    #   all of them.
    # @return [void]
    def run_servers(do_fork = true, which = [])
      each_server do |server, name|
        puts name
        next unless which.empty? or which.include?(name)

        if File.exists?(server[:files][:pid])
          Supernova.logger.warn {
            "PID file #{server[:files][:pid]} already exists. " +
            "Ignoring server definition."
          }
          next
        end

        if do_fork
          process_id = fork
        end

        if process_id
          File.open(server[:files][:pid], "w") { |f| f.write process_id }
          Process.detach(process_id)
        else
          if do_fork
            Supernova.logger = Logger.new(server[:files][:log], 10, 1_024_000)
            $stdin = $stdout = $stderr = File.open("/dev/null", "a")
          end

          if server[:files][:client]
            require server[:files][:client]
          end

          s = Supernova::Starbound::Server.new(server)
          trap('INT') {
            s.shutdown
            File.delete(server[:files][:pid]) rescue Errno::ENOENT
          }
          return s.listen
        end
      end
    end

    # Takes down running servers.
    #
    # @param which [Array<String>] which servers to take down.
    #   Defaults to all of them.
    # @return [void]
    def shoot(which = [])
      puts "Shooting..."
      each_server do |server, name|
        next unless which.empty? or which.include?(name)

        p server

        if File.exists?(server[:files][:pid])
          pid = File.open(server[:files][:pid], "r") { |f| f.read }.to_i

          puts "Sending INT to #{pid}..."

          Process.kill :INT, pid rescue Errno::ESRCH

          File.delete(server[:files][:pid]) rescue Errno::ENOENT
        end
      end
    end

    private

    # Loops over all of the defined servers, yielding the server
    # definition and the index for that server.
    #
    # @yieldparam server [Hash<Symbol, Object>] the server data
    # @yieldparam server_name [String] the name of the server.
    # @yieldparam index [Numeric] the index of the server in the
    #   definition file.
    # @return [void]
    def each_server
      server_list = [options["servers"], options["server"]].flatten.compact

      server_list.each_with_index do |srv, i|
        srv_name = srv.fetch(:name, "server#{i}")
        srv[:files] ||= {}

        files = {}
        {:log => :log, :pid => :pid, :client => :rb}.each do |f, n|
          files[f] = File.absolute_path(
            srv[:files].fetch(f, "./#{srv_name}.#{n}"),
            directory.path
          )
        end
        srv[:files] = files

        yield srv, srv_name, i
      end
    end

  end
end
