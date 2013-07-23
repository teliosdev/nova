module Nova
  module Remote

    # This is a part of a remote.  This sets up the initializion for
    # the parts, and maybe later some other things.
    class Part

      # The remote this is a part of.
      #
      # @return [Object] the remote.
      attr_reader :remote

      # Initialize the part.
      #
      # @param remote [Object] the remote.
      def initialize(remote)
        @remote = remote
      end

    end
  end
end