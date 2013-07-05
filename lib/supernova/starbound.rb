module Supernova

  # The networking module of Supernova.  It's meant to be fast,
  # secure, and cross-platform compatible.
  module Starbound

    autoload :Protocol, "supernova/starbound/protocol"
    autoload :Encryptor, "supernova/starbound/encryptor"
    autoload :Encryptors, "supernova/starbound/encryptors"
    autoload :Client, "supernova/starbound/client"
    autoload :Server, "supernova/starbound/server"

  end
end
