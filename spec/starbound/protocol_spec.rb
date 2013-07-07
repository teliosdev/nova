require 'stringio'

describe Supernova::Starbound::Protocol do
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
    subject.should be_a Supernova::Starbound::Protocol

    subject.state.should be :offline
  end

  context "client performing handshake" do
    subject { described_class.new(:threaded => false, :type => :client) }

    before :each do
      subject.socket = @client
      @thread = Thread.start { subject.handshake }
      sleep 0.1
    end

    it "should send the protocol version" do
      pack = SupernovaHelper.packet_from_socket(@server_client)
      pack.body.should eq Supernova::VERSION

      @thread.exit
    end

    it "checks versions" do
      pack = SupernovaHelper.packet_from_socket(@server_client)
      @server_client.write SupernovaHelper.build_response(:protocol_version, "200.0.0", pack)

      expect {
        @thread.join
      }.to raise_error Supernova::Starbound::IncompatibleRemoteError
    end

    it "checks for encryption" do

      pack = SupernovaHelper.packet_from_socket(@server_client)
      @server_client.write SupernovaHelper.build_response(:protocol_version, Supernova::VERSION, pack)

      encrypt = SupernovaHelper.packet_from_socket(@server_client)
      encrypt.body.should eq "rbnacl/1.0.0\nopenssl/rsa-4096/aes-256-cbc\nplaintext"

      @thread.exit
    end

    it "does encryption" do
      pack = SupernovaHelper.packet_from_socket(@server_client)
      @server_client.write SupernovaHelper.build_response(:protocol_version, Supernova::VERSION, pack)

      encrypt = SupernovaHelper.packet_from_socket(@server_client)
      encrypt.body.should eq "rbnacl/1.0.0\nopenssl/rsa-4096/aes-256-cbc\nplaintext"
      enc = Supernova::Starbound::Encryptors::RbNaCl.new
      enc.private_key!

      @server_client.write SupernovaHelper.build_response(:public_key, "rbnacl/1.0.0\n" + enc.public_key, encrypt)

      response = SupernovaHelper.packet_from_socket(@server_client)

      enc.other_public_key = response.body

      @thread.join
    end

    it "closes the socket" do
      pack = SupernovaHelper.packet_from_socket(@server_client)
      @server_client.write SupernovaHelper.build_response(:protocol_version, Supernova::VERSION, pack)

      encrypt = SupernovaHelper.packet_from_socket(@server_client)
      encrypt.body.should eq "rbnacl/1.0.0\nopenssl/rsa-4096/aes-256-cbc\nplaintext"
      enc = Supernova::Starbound::Encryptors::RbNaCl.new
      enc.private_key!

      @server_client.write SupernovaHelper.build_response(:public_key, "rbnacl/1.0.0\n" + enc.public_key, encrypt)
      response = SupernovaHelper.packet_from_socket(@server_client)
      enc.other_public_key = response.body

      subject.close

      close_enc = SupernovaHelper.packet_from_socket(@server_client)
      close = enc.decrypt(close_enc)
      close.type.should be :close
      close.body.should eq "0"

      subject.state.should be :offline
    end
  end
end
