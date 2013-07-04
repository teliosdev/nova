require 'supernova/commands/server'
module Supernova
  class CLI < ::Thor

    include Thor::Actions

    class_option :path, :type => :string, :default => "."

    def self.source_root
      File.absolute_path("../../generator/template", __FILE__)
    end

    desc "install PATH", "Installs a Galaxy into the given path."
    def install(to)
       directory("new_install", to)
    end

    desc "list", "List all of the available stars."
    def list
      project.require_files

      Star.stars.each do |key, value|
        shell.say("#{key}:", :green, :bold)

        value.each do |k, v|
          shell.say "\t#{k}"
        end
      end
    end

    desc "server SUBCOMMAND [...ARGS]", "Manage supernova servers."
    subcommand "server", Commands::Server

    private

    def project
      @_project ||= Project.new(options[:path])
    end
  end
end

# Subcommands and other stuff to be used with thor.
module Commands; end
