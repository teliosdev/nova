require 'socket'
require 'timeout'

describe Nova::Starbound::Protocol do

  before :each do 
    @unix_server = UNIXServer.open("protocol.sock")
    @client = UNIXSocket.open("protocol.sock")
    @server = @unix_server.accept
  end
  
  around :each do |example|
    Timeout::timeout(15) { example.run }
  end

  after :each do
    @client.close unless @client.closed?
    @server.close unless @server.closed?
    @unix_server.close unless @unix_server.closed?
    File.unlink("protocol.sock")
  end

  subject {
    described_class.new(options)
  }

  let(:options) { {} }

  it "initializes correctly" do
    expect(subject).to be_a Nova::Starbound::Protocol
    expect(subject.state).to be :offline
  end

  context "client performing handshake" do
    let(:options) { {:threaded => false, :type => :client} }

    before :each do
      subject.socket = @client
      @thread = Thread.start { subject.handshake }
      sleep 0.1
    end

    it "checks versions" do
      pack = NovaHelper.packet_from_socket(@server)
      @server.write NovaHelper.build_response(:protocol_version, "200.0.0", pack)

      expect { @thread.join }.to raise_error(Nova::Starbound::IncompatibleRemoteError)
    end

    it "handles encryption" do
      pack = NovaHelper.packet_from_socket(@server)
      expect(pack.body).to eq Nova::VERSION
      expect(subject.state).to be :handshake
      @server.write NovaHelper.build_response(:protocol_version, Nova::VERSION, pack)

      encrypt = NovaHelper.packet_from_socket(@server)
      expect(encrypt.body).to eq "rbnacl/1.0.0\nopenssl/rsa-4096/aes-256-cbc\nplaintext"
      enc = Nova::Starbound::Encryptors::RbNaCl.new
      enc.private_key!

      @server.write NovaHelper.build_response(:public_key, "rbnacl/1.0.0\n" + enc.public_key, encrypt)

      response = NovaHelper.packet_from_socket(@server)

      enc.other_public_key = response.body

      expect(subject.state).to be :online

      subject.close

      close_enc = NovaHelper.packet_from_socket(@server)
      close = enc.decrypt(close_enc)
      expect(close.type).to be :close
      expect(close.body).to eq "0"

      expect(subject.state).to be :offline
    end
  end

  context "server performing handshake" do
    let(:options) { {:type => :server} }

    before :each do
      subject.socket = @server
      @thread = Thread.start { subject.handshake }
    end

    it "checks protocol versions" do
      @client.write NovaHelper.build_packet(:protocol_version, "200.0.0")

      expect { @thread.join }.to raise_error(Nova::Starbound::IncompatibleRemoteError)
    end

    it "handles the handshake" do
      @client.write NovaHelper.build_packet(:protocol_version, Nova::VERSION)
      version = NovaHelper.packet_from_socket(@client)
      expect(version.body).to eq Nova::VERSION

      @client.write NovaHelper.build_packet(:encryption_options, "rbnacl/1.0.0", :packet_id => 2, :nonce => "")
      enc_packet = NovaHelper.packet_from_socket(@client)

      enc = Nova::Starbound::Encryptors::RbNaCl.new
      enc.private_key!
      sent_enc, enc.other_public_key = enc_packet.body.split("\n", 2)
      expect(sent_enc).to eq "rbnacl/1.0.0"

      @client.write NovaHelper.build_response(:public_key, enc.public_key, enc_packet)

      sleep 0.5

      expect(subject.state).to be :online

      thing = double('thing')
      thing.should_receive(:packet_echo)

      subject.on(:packet => :echo) { thing.packet_echo } 
      packet = NovaHelper.build_packet(:echo, "hello", :packet_id => 3)
      enc_packet = enc.encrypt(packet)
      @client.write enc_packet

      subject.read

      subject.close

      @thread.join

    end
  end

end

require 'pp'