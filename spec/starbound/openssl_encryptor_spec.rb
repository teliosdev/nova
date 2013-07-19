describe Nova::Starbound::Encryptors::OpenSSL do

  it "is available" do
    expect(described_class).to be_available
  end

  context "handling keys" do
    subject { described_class.new }
    its(:private_key!) { should be_instance_of ::OpenSSL::PKey::RSA }

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

    secret = ::OpenSSL::Random.random_bytes(4096 / 16)
    encrypted_secret = ::OpenSSL::PKey::RSA.new(public_key).public_encrypt(secret)

    subject.other_public_key = encrypted_secret

    expect(subject.options[:shared_secret]).to eq secret
    encrypted = nil

    expect {
      encrypted = subject.encrypt(@packet)
    }.to_not raise_error

    expect(encrypted).to be_instance_of Nova::Starbound::Protocol::Packet
    expect(encrypted.body.bytesize).to eq encrypted[:size]
  end

  it "decrypts a packet successfully" do

    subject.private_key!

    public_key = ::OpenSSL::PKey::RSA.new(4096)
    subject.other_public_key = public_key.public_key.to_der
    encrypted_secret = subject.public_key

    secret = public_key.private_decrypt(encrypted_secret)
    expect(secret).to eq subject.options[:shared_secret]

    encrypted = subject.encrypt(@packet)
    decrypted = nil

    expect {
      decrypted = subject.decrypt(encrypted)
    }.to_not raise_error

    expect(decrypted.body).to eq @packet.body
  end

  it "raises an error on non-matching hashes" do
    subject.private_key!
    public_key = subject.public_key

    secret = ::OpenSSL::Random.random_bytes(4096 / 16)
    encrypted_secret = ::OpenSSL::PKey::RSA.new(public_key).public_encrypt(secret)

    subject.other_public_key = encrypted_secret

    encrypted = subject.encrypt(@packet)
    encrypted.body.replace("\x00" * encrypted.size)

    expect {
      subject.decrypt(encrypted)
    }.to raise_error(Nova::Starbound::EncryptorError)
  end

end
