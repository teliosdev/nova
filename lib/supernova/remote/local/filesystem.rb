require 'fileutils'

# open-uri invalidates the method cache every time it opens a url.
# sadface :(
require 'open-uri'

module Supernova
  module Remote
    module Local

      # @TODO: windows support
      #   {#untar_file} and {#unzip_file} are not windows-friendly.
      module Filesystem

        # Grabs the file from file and puts it somewhere else.  If
        # it's a local file (checked by #file_exists?), it just copies
        # it.  If it's not, it opens a connection to the server to try
        # to download the file.
        #
        # @param file [String] the file to download.  Can be a path
        #   name or URI.
        # @param options [Hash{Symbol => Object}] the options for
        #   grabbing the files.
        # @option options [String] :to the file to save to.  If this
        #   doesn't exist, it's guessed from the file name.
        # @option options [Boolean, String] :decompress the file after
        #   saving it.  If it's a string, the decompressed file is
        #   extracted there.  Otherwise, it's guessed from the
        #   filename.
        # @return [true]
        def grab_file(file, options = {})
          destination = options.fetch(:to, File.basename(file))
          Supernova.logger.info { "Retrieving file #{file} to #{destination}..." }

          if file_exists?(file)
            FileUtils.copy(file, destination)
          else
            File.open(destination, "w") do |f|
              out = open(file)
              while not out.eof?
                ary, = IO.select [out], nil, nil, 0.1
                f.write out.readpartial(1024) if ary[0]
              end

              out.close
            end
          end

          if options[:decompress]
            decompress_dest = options[:decompress]

            if decompress_dest == true
              decompress_dest = File.basename(destination, File.extension(destination))
            end
            decompress_file destination, decompress_dest
          end

          true
        end

        # Checks to see if the file exists on the file system.
        #
        # @param file [String] the file to check.
        # @return [Boolean]
        def file_exists?(file)
          File.exists?(file)
        end

        # Decompress the given file, to the given directory.
        #
        # @todo support more compressed formats.
        # @param file [String] the file to decompress.
        # @param to [String] the directory to decompress to.
        # @return [void]
        def decompress_file(file, to)
          Supernova.logger.info { "Decompressing file #{file} to directory #{to}..." }
          FileUtils.mkpath(to)

          data = line("file", "--mime-type {file}").pass(file: file)
          mime = data.stdout.split(': ')[1]

          case mime
          when "application/x-gzip"
            untar_file(file, to)
          when "application/zip"
            unzip_file(file, to)
          when "application/x-7z-compressed"
            unszip_file(file, to)
          else
            Supernova.logger.error { "Unknown file type: #{mime}" }
          end
        end

        private

        # Untars the given file.
        #
        # @param f [String] the path to the file to untar.
        # @param to [String] the path to the destination.
        # @return [Command::Runner::Message] the process data.
        def untar_file(f, to)
          line("tar", "-xf {file} -C {path}").pass(file: f, path: to)
        end

        # Unzips the file.
        #
        # @param f [String] the path to the file to unzip.
        # @param to [String] the path to the destination.
        # @return [Command::Runner::Message] the process data.
        def unzip_file(f, to)
          line("unzip", "{file} -d {path}").pass(file: f, path: to) do |m|
            if m.no_command?
              line("gunzip", "{file} -d {path}").pass(file: f, path: to)
            else
              m
            end
          end
        end

        # Un 7zips a file.
        #
        # @param f [String] the path to the file.
        # @param to [String] the path to the destination.
        # @return [Command::Runner::Message] the process data.
        def unszip_file(f, to)
          line("7z", "x -y {archive} -o{dest} * -r").pass(archive: f, dest: to)
        end

      end
    end
  end
end
