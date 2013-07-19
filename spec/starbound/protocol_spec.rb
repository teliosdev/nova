require 'stringio'

describe Nova::Starbound::Protocol do
  before :each do
    @server = UNIXServer.open("protocol.sock")
    @client = UNIXSocket.open("protocol.sock")
    @server_client = @server.accept
  end

  after :each do
    @client.close if @client && !@client.closed?
    @server_client.close if @server_client && !@server_client.closed?
    @server.close if @server
    File.delete("protocol.sock")
  end

  it "initializes correctly" do
    expect(subject).to be_a Nova::Starbound::Protocol

    expect(subject.state).to be :offline
  end

  context "client performing handshake" do
    subject { described_class.new(:threaded => false, :type => :client) }

    before :each do
      subject.socket = @client
      @thread = Thread.start { subject.handshake }
      sleep 0.1
    end

    it "sends the protocol version" do
      pack = NovaHelper.packet_from_socket(@server_client)
      expect(pack.body).to eq Nova::VERSION
      expect(subject.state).to be :handshake

      @thread.exit
    end

    it "checks versions" do
      pack = NovaHelper.packet_from_socket(@server_client)
      @server_client.write NovaHelper.build_response(:protocol_version, "200.0.0", pack)

      expect {
        @thread.join
      }.to raise_error Nova::Starbound::IncompatibleRemoteError
    end

    it "checks for encryption" do

      pack = NovaHelper.packet_from_socket(@server_client)
      @server_client.write NovaHelper.build_response(:protocol_version, Nova::VERSION, pack)

      encrypt = NovaHelper.packet_from_socket(@server_client)
      expect(encrypt.body).to eq "rbnacl/1.0.0\nopenssl/rsa-4096/aes-256-cbc\nplaintext"

      @thread.exit
    end

    it "does encryption" do
      pack = NovaHelper.packet_from_socket(@server_client)
      @server_client.write NovaHelper.build_response(:protocol_version, Nova::VERSION, pack)

      encrypt = NovaHelper.packet_from_socket(@server_client)
      expect(encrypt.body).to eq "rbnacl/1.0.0\nopenssl/rsa-4096/aes-256-cbc\nplaintext"
      enc = Nova::Starbound::Encryptors::RbNaCl.new
      enc.private_key!

      @server_client.write NovaHelper.build_response(:public_key, "rbnacl/1.0.0\n" + enc.public_key, encrypt)

      response = NovaHelper.packet_from_socket(@server_client)

      enc.other_public_key = response.body

      @thread.join
    end

    it "closes the socket" do
      pack = NovaHelper.packet_from_socket(@server_client)
      @server_client.write NovaHelper.build_response(:protocol_version, Nova::VERSION, pack)

      encrypt = NovaHelper.packet_from_socket(@server_client)
      expect(encrypt.body).to eq "rbnacl/1.0.0\nopenssl/rsa-4096/aes-256-cbc\nplaintext"
      enc = Nova::Starbound::Encryptors::RbNaCl.new
      enc.private_key!

      @server_client.write NovaHelper.build_response(:public_key, "rbnacl/1.0.0\n" + enc.public_key, encrypt)
      response = NovaHelper.packet_from_socket(@server_client)
      enc.other_public_key = response.body

      expect(subject.state).to be :online

      subject.close

      close_enc = NovaHelper.packet_from_socket(@server_client)
      close = enc.decrypt(close_enc)
      expect(close.type).to be :close
      expect(close.body).to eq "0"

      expect(subject.state).to be :offline
    end
  end

  context "server performing handshake" do
    subject { described_class.new(:type => :server) }

    before :each do
      subject.socket = @server_client
      @thread = Thread.start { subject.handshake }
      sleep 0.1
    end

    it "checks protocol versions" do
      @client.write NovaHelper.build_packet(:protocol_version, "200.0.0")

      expect {
        @thread.join
      }.to raise_error Nova::Starbound::IncompatibleRemoteError
    end

    it "sends back the protocol version" do
      @client.write NovaHelper.build_packet(:protocol_version, Nova::VERSION)

      version = NovaHelper.packet_from_socket(@client)
      expect(version.body).to eq Nova::VERSION
      @thread.exit
    end

    it "selects the correct encryption" do
      @client.write NovaHelper.build_packet(:protocol_version, Nova::VERSION)
      version = NovaHelper.packet_from_socket(@client)
      @client.write NovaHelper.build_packet(:encryption_options, "rbnacl/1.0.0")
      enc = NovaHelper.packet_from_socket(@client)
      expect(enc.body.split("\n").first).to eq "rbnacl/1.0.0"
      @thread.exit
    end

    it "does encryption" do
      @client.write NovaHelper.build_packet(:protocol_version, Nova::VERSION)
      version = NovaHelper.packet_from_socket(@client)
      @client.write NovaHelper.build_packet(:encryption_options, "rbnacl/1.0.0", :packet_id => 2, :nonce => "")
      enc_packet = NovaHelper.packet_from_socket(@client)

      enc = Nova::Starbound::Encryptors::RbNaCl.new
      enc.private_key!
      enc.other_public_key = enc_packet.body.split("\n", 2).last

      @client.write NovaHelper.build_response(:public_key, enc.public_key, enc_packet)

      #expect(subject.state).to be :online
      subject.on(:packet => :echo) { throw(:packet_echo) }
      packet = NovaHelper.build_packet(:echo, "hello", :packet_id => 3)
      enc_packet = enc.encrypt(packet)
      @client.write enc_packet

      expect {
        subject.thread.join
      }.to throw_symbol(:packet_echo)

      @thread.join
    end
  end
end
