describe Nova::Starbound::Encryptors::RbNaCl do

  it "is available" do
    expect(described_class).to be_available
  end

  context "handling keys" do
    subject { described_class.new }
    its(:private_key!) { should be_a ::Crypto::PrivateKey }

    it "has a public key" do
      subject.private_key! # initialize the private key
      expect(subject.public_key).to be_a String
    end
  end

  before :each do
    @packet = NovaHelper.build_packet
  end

  it "encrypts a packet successfully" do
    subject.private_key!
    public_key = subject.public_key

    our_private = ::Crypto::PrivateKey.generate

    subject.other_public_key = our_private.public_key.to_bytes
    encrypted = nil

    expect {
      encrypted = subject.encrypt(@packet)
    }.to_not raise_error

    expect(encrypted).to be_instance_of Nova::Starbound::Protocol::Packet
    expect(encrypted.body.bytesize).to eq encrypted[:size]
  end

  it "decrypts a packet successfully" do
    subject.private_key!

    our_private = ::Crypto::PrivateKey.generate
    subject.other_public_key = our_private.public_key.to_bytes
    their_public = subject.public_key

    encrypted = subject.encrypt(@packet)
    decrypted = nil

    expect {
      #decrypted = subject.decrypt(encrypted)
      box = ::Crypto::Box.new(their_public, our_private)
      decrypted = box.decrypt(encrypted[:nonce], encrypted[:body])
    }.to_not raise_error

    expect(decrypted).to eq @packet.body
  end

  it "raises an error on non-matching hashes" do
    subject.private_key!
    public_key = subject.public_key

    subject.other_public_key = ::Crypto::PrivateKey.generate.public_key.to_bytes

    encrypted = subject.encrypt(@packet)
    encrypted.body.replace("\x00" * encrypted.size)

    expect {
      subject.decrypt(encrypted)
    }.to raise_error(Nova::Starbound::EncryptorError)
  end
end
