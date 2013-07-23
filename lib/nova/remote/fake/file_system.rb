module Nova
  module Remote
    class Fake

      # Handles filesystem stuff, like downloading files and
      # decompressing fles.
      #
      # @abstract
      class FileSystem < Part

        # Grabs the file from file and puts it somewhere else.  If
        # it's a local file (checked by #file_exists?), it just copies
        # it.  If it's not, it opens a connection to the server to try
        # to download the file.
        #
        # @note Does nothing.
        # @abstract
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
        # @return [Boolean]
        def grab_file(file, options = {})
          false
        end

        # Checks to see if the file exists on the file system.
        #
        # @note Does nothing.
        # @abstract
        # @param file [String] the file to check.
        # @return [Boolean]
        def file_exists?(file)
          false
        end

        # Decompress the given file, to the given directory.
        #
        # @note Does nothing.
        # @abstract
        # @param file [String] the file to decompress.
        # @param to [String] the directory to decompress to.
        # @return [void]
        def decompress_file(file, to)
        end

        private

        # Untars the given file.
        #
        # @note Does nothing.
        # @abstract
        # @return [void]
        def untar_file(f, to)
        end

        # Unzips the file.
        #
        # @note Does nothing.
        # @abstract
        def unzip_file(f, to)
        end

        # Unrars the given file.
        #
        # @note Does nothing.
        # @abstract
        def unrar_file(f, to)
        end
      end
    end
  end
end
