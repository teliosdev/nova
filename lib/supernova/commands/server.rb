module Supernova
  module Commands

    # Handles server operations for projects.
    class Server < ::Thor

      desc "up", "Runs the servers."
      method_option :foreground, :type => :boolean,
        :desc => "Run the process in the foreground.",
        :default => false
      method_option :which, :type => :array, :banner => "<servers>",
        :desc => "Which servers to run.  Empty means all.",
        :default => []
      long_desc <<-DESC
      Runs servers defined in supernova.yml.  If the forgeground
      option is specified, the process is run in the foreground.
      Otherwise, it's ran as a daemon.  If the which parameter is
      specified, it only runs the servers that were specified.

      Options that can be defined for servers include:

        :name    :: the name of the server.  Used to name the pid
                    files and the log files.

        :type    :: the type of server.  Can be :tcp or :unix.  If
                    it's :tcp, options :ip and :port can be defined
                    and will be used.  If it's :unix, the option :path
                    can be defined for the path to the socket.
                    Defaults to :tcp.

        :host    :: the IP address to bind to.  Only applicable if
                    :type is :tcp.  Defaults to 127.0.0.1.

        :port    :: the port to bind to.  Only applicable if :type is
                    :tcp.  Defaults to 2010.

        :path    :: the path to the UNIX socket.  Only applicable if
                    :type is :unix.  Defaults to /tmp/sock.

        :protocol:: protocol options, used for settings in the
                    protocol. only current option is :allow_plaintext,
                    which prevents the server from raising an
                    exception if the  protocol negotiates a plaintext
                    encryption (insecure).
      DESC
      # Runs the servers.  Run +supernova server help up+ for
      # information on this command.
      #
      # @see Project
      # @see Project#run_servers
      # @return [void]
      def up
        Project.new(parent_options[:path]).run_servers(
          !options[:foreground], options[:which])
      end

      desc "down", "Takes down running servers."
      method_option :which , :type => :array, :banner => "<servers>",
        :desc => "Which servers to remove.  Empty means all.",
        :default => []
      # Handles taking down servers.
      #
      # @see Project
      # @see Project#shoot
      # @return [void]
      def down
        Project.new(parent_options[:path]).shoot(options[:which])
      end
    end
  end
end
