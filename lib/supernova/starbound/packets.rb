require 'packed_struct'

module Supernova
  module Starbound
    module Packets

      extend PackedStruct

      #RBNACL_PUBLIC_KEY = 0x00
      #ECHO = 0x01
      #CLOSE = 0x02
      #PASSWORD_AUTH = 0x03

      Type = {
        :nul             => 0x00,
        # 0x01 - 0x0f are for encryption agreement
        :encrypt_options => 0x01,
        :rbnacl_encrypt  => 0x02,
        :openssl_encrypt => 0x03,

        # 0x10 - 0x1f are for basic responses
        :ok              => 0x10,
        :error           => 0x11,
        :unsupported     => 0x12
      }


      STRUCT_MAPS = {
        :packet   => 0x00,
        :response => 0x01,
        :encrypt_agreement => 0x02
      }

      struct_layout :basic_packet do
        little_endian unsigned size[32]
        unsigned encrypted[8]
        unsigned struct[8]
        little string nonce[24]
        string digest[20]
        string body[size]
        null
      end

      struct_layout :packet do
        little_endian unsigned size[32]
        little_endian unsigned packet_id[32]
        unsigned packet_type[8]
        string body[size]
        null
      end

      struct_layout :response do
        little_endian unsigned size[32]
        little_endian unsigned packet_response_id[32]
        unsigned packet_response_type[8]
        little_endian unsigned packet_id[32]
        unsigned packet_type[8]
        string body[size]
        null
      end

      struct_layout :encrypt_agreement do
        little_endian unsigned size[32]
        unsigned crypt_type[8]
        string public_key[size]
        null
      end

    end
  end
end
