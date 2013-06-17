require 'fileutils'
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

          f = File.open(file, "r")
          top = f.read(4)
          f.seek(0)

          if top[0..1] == "\x1f\x8b" # it's a GZIP file.
            untar_file f, to
          elsif top[0..3] == "\x50\x4B\003\004" || top[0..3] == "\x50\x4B\005\006" || top[0..3] == "\x50\x4B\007\b" # it's a zip file.
            unzip_file f, to
          end
        end

        private

        # Untars the given file.
        #
        # @todo windows support.
        def untar_file(f, to)
          FileUtils.mkpath(to)
          line("tar", "-xf :file -C :path").run(file: f.to_path, path: to)
        end

        # Unzips the file.
        #
        # @todo windows support.
        def unzip_file(f, to)
          FileUtils.mkpath(to)

          begin
            line("unzip", ":file -d :path", file: f.to_path, path: to)
          rescue Cocaine::CommandNotFoundError
            line("gunzip", ":file -d :path", file: f.to_path, path: to)
          end
        end

      end
    end
  end
end
