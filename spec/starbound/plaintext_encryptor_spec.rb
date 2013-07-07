describe Supernova::Starbound::Encryptors::Plaintext do
  it "is available" do
    described_class.should be_available
  end

  it "is plaintext" do
    described_class.should be_plaintext
  end

  it "encrypts correctly" do
    packet = SupernovaHelper.build_packet

    out_packet = subject.encrypt(packet)
    out_packet.body.should eq packet.body
    out_packet.nonce.length.should be 24
  end

  it "decrypts correctly" do
    packet = SupernovaHelper.build_packet

    packet[:nonce] = Random.new.bytes(24)
    out_packet = subject.decrypt(packet)

    out_packet.body.should eq packet.body
    out_packet[:nonce].should eq packet[:nonce]
  end
end
