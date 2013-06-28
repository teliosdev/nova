require 'supernova/remote/local/platforms'
require 'supernova/remote/local/commands'
require 'supernova/remote/local/filesystem'
require 'supernova/remote/local/operating_system'

module Supernova
  module Remote

    # Manages the Local platform for {Star}s.
    module Local

      include Local::Platforms
      include Local::Commands
      include Local::Filesystem
      include Local::OperatingSystem

      extend self
    end
  end
end
