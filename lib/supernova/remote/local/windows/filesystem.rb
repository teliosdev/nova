module Supernova
module Remote
  module Local

    # Adds Windows compatibility to the Local remote.
    module Windows

      # Filesystem operations.
      module Filesystem

        # Decompresses files on windows.  This assumes a) that 7-zip
        # is installed, b) is the alone version, and c) is in the
        # PATH.
        #
        # @param file [String] the archive to decompress.
        # @param to [String] the directory to decompress it to.
        # @return [Command::Runner::Message] the result of the
        #   decompression.
        def decompress_file(file, to)
          FileUtils.mkpath(to)
          line("7za", "x -y {archive} -o{dest} * -r").pass(archive: file, dest: to)
        end

        # Checks if a command exists.
        #
        # @param command [String] the command to check.
        def command_exists?(command)
          !line("powershell", "gcm {command}").pass(command: command).no_command?
        end

      end
    end
  end
end
end
