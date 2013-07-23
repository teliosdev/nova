require 'uri'
require 'openssl'
require 'net/http'
require 'net/https'
require 'net/ftp'
require 'tempfile'

module Nova
  module Remote
    class Local

      # Handles filesystem stuff, like downloading files and
      # decompressing fles.
      class FileSystem < Part

        # How many bytes to read to a chunk.
        READ_CHUNKS = 2048

        # The file where the CA Certs are stored.  This should be the
        # file's contents, not the file itself.
        CACERT_FILE = File.open(File.expand_path("../../../../../cacert.pem", __FILE__), "r") { |f| f.read }

        # Grabs the file from file and puts it somewhere else.  If
        # it's a local file, it just copies
        # it.  If it's not, it opens a connection to the server to try
        # to download the file.  Local files must have the protocol
        # +file://+ prefixing them, otherwise this will not be able to
        # determine what files it needs to download.
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
        # @return [Boolean]
        def grab_file(file, options = {})
          uri = URI(file)
          dest = options[:to] || File.basename(uri.path)

          out = case uri.scheme.downcase
          when 'ftp'
            ftp_download(uri, dest)
          when 'http', 'https'
            http_download(uri, dest)
          when 'file'
            file_download(uri, dest)
          else
            raise IOError, "Unkown protocol #{uri.scheme}"
          end

          if out && options[:decompress]
            decompress = if options[:decompress].is_a? String
              options[:decompress]
            else
              dest.gsub(/#{Regexp.escape File.extname(dest)}\z/, "")
            end

            decompress_file(dest, decompress)
          else
            out
          end
        end

        # Checks to see if the file exists on the file system.
        #
        # @note Does nothing.
        # @abstract
        # @param file [String] the file to check.
        # @return [Boolean]
        def file_exists?(file)
          File.exists?(file)
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

        # Downloads a file via FTP.  Uses net/ftp.  
        #
        # @param from [URI] the URI of the place to download from.
        # @param to [String] the place to put the file.
        # @return [Boolean]
        def ftp_download(from, to)
          ftp = Net::FTP.new(from.hostname)
          ftp.login from.user || "anonymous", from.password
          ftp.chdir(File.dirname(from.path))
          FileUtils.mkdir_p File.dirname(to)
          ftp.getbinaryfile(File.basename(from.path), to, READ_CHUNKS) {}
          ftp.close
          true
        end

        # Handles downloading from an HTTP/HTTPS server.  If it's an
        # HTTPS server, it validates the given certificate with the 
        # CACert bundled with the library.
        #
        # @param from [URI] the URI of the place to download from.
        # @param to [String] the place to put the file.
        # @return [Boolean]
        def http_download(from, to)
          http = Net::HTTP.new(from.host, from.port)
          FileUtils.mkdir_p File.dirname(to)
          out = File.open(to, "wb")

          if from.scheme == 'https'
            http.use_ssl = true
            http.cert = @_open_ssl_cert ||= OpenSSL::X509::Certificate.new(pem)
            http.key  = @_open_ssl_key  ||= OpenSSL::PKey::RSA.new(pem)
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end

          http.request_get(from.request_uri) do |response|
            unless response === Net::HTTPOK
              raise response
            end

            response.read_body { |ch| out.write ch }
          end

          http.finish
          out.close
          true 

        ensure
          out.close
          false

        end

        # We were given a file path to download, so we just copy the
        # file from the local path to the given path.
        #
        # @param from [URI] the file URI to copy from.
        # @param to [String] the destination.
        # @return [Boolean]
        def file_download(from, to)
          FileUtils.mkdir_p File.dirname(to)
          file = File.open(from.path, "rb")

          File.open(to, "wb") do |out|
            while !file.eof?
              out.write(file.read(READ_CHUNKS))
            end
          end

          file.close
          true
        end

      end
    end
  end
end
