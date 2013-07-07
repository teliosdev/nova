describe Supernova::Starbound::Encryptors::Plaintext do
  it "is available" do
    expect(described_class).to be_available
  end

  it "is plaintext" do
    expect(described_class).to be_plaintext
  end

  it "encrypts correctly" do
    packet = SupernovaHelper.build_packet

    out_packet = subject.encrypt(packet)
    expect(out_packet.body).to eq packet.body
    expect(out_packet.nonce.length).to be 24
  end

  it "decrypts correctly" do
    packet = SupernovaHelper.build_packet

    packet[:nonce] = Random.new.bytes(24)
    out_packet = subject.decrypt(packet)

    expect(out_packet.body).to eq packet.body
    expect(out_packet[:nonce]).to eq packet[:nonce]
  end
end
