require 'nova/commands/server'
module Nova

  # Handles the command line interface.  Uses thor to do that.
  class CLI < ::Thor

    include Thor::Actions

    class_option :path, :type => :string, :default => "."

    # The source thor should use for managing files.
    #
    # @api private
    # @return [String]
    def self.source_root
      File.absolute_path("../../generator/template", __FILE__)
    end

    desc "install PATH", "Installs a Galaxy into the given path."
    # Installs a galaxy into the given path.  Just copies the files
    # and folders in lib/generator/template/new_install into the
    # given folder.
    #
    # @return [void]
    def install(to)
       directory("new_install", to)
    end

    desc "list", "List all of the available stars."
    # Lists all of the stars that the project has available to it.
    # Requires the --path parameter or to be in a project folder.
    #
    # @return [void]
    def list
      project.require_files

      Star.stars.each do |key, value|
        shell.say("#{key}:", :green, :bold)

        value.each do |k, v|
          shell.say "\t#{k}"
        end
      end
    end

    desc "cmd", "Opens a shell for use."
    # Opens a blank shell using {Shell}.
    #
    # @return [void]
    def cmd
      cmd = Nova::Shell.new(self)
      cmd.start_shell
    end

    desc "server SUBCOMMAND [...ARGS]", "Manage Nova servers."
    subcommand "server", Commands::Server

    private

    # Returns the project instance for the folder.
    #
    # @see Project
    # @return [Project]
    def project
      @_project ||= Project.new(options[:path])
    end
  end
end

# Subcommands and other stuff to be used with thor.
module Nova::Commands; end
