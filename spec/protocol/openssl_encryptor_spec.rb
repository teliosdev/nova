describe Supernova::Starbound::Encryptors::OpenSSL do

  it "is available" do
    described_class.should be_available
  end

  context "handling keys" do
    subject { described_class.new }
    its(:private_key!) { should be_instance_of ::OpenSSL::PKey::RSA }

    it "has a public key" do
      subject.private_key! # initialize the private key
      subject.public_key.should be_a String
    end
  end

  before :each do
    @packet = SupernovaHelper.build_packet
  end

  it "encrypts a packet successfully" do

    subject.private_key!
    public_key = subject.public_key

    secret = ::OpenSSL::Random.random_bytes(4096 / 16)
    encrypted_secret = ::OpenSSL::PKey::RSA.new(public_key).public_encrypt(secret)

    subject.other_public_key = encrypted_secret

    subject.options[:shared_secret].should eq secret
    encrypted = nil

    expect {
      encrypted = subject.encrypt(@packet)
    }.to_not raise_error

    encrypted.should be_instance_of Supernova::Starbound::Protocol::Packet
    encrypted.body.bytesize.should eq encrypted[:size]
  end

  it "decrypts a packet successfully" do

    subject.private_key!

    public_key = ::OpenSSL::PKey::RSA.new(4096)
    subject.other_public_key = public_key.public_key.to_der
    encrypted_secret = subject.public_key

    secret = public_key.private_decrypt(encrypted_secret)
    secret.should eq subject.options[:shared_secret]

    encrypted = subject.encrypt(@packet)
    decrypted = nil

    expect {
      decrypted = subject.decrypt(encrypted)
    }.to_not raise_error

    decrypted.body.should eq @packet.body
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
    }.to raise_error(Supernova::Starbound::EncryptorError)
  end

end
