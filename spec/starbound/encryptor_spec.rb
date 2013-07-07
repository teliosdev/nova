describe Supernova::Starbound::Encryptor do

  it "is not available" do
    expect(described_class).to_not be_available

    expect {
      subject
    }.to raise_error NotImplementedError
  end

  it "is not plaintext" do
    expect(described_class).to_not be_plaintext
  end

  it "sorts the encryptors" do
    expect(described_class.sorted_encryptors).to have(3).items
    expect(described_class.sorted_encryptors.first.preference).to be > described_class.sorted_encryptors.last.preference
  end

  context "encrypting" do
    before(:each) { described_class.stub(:available?).and_return(true) }

    it "raises errors" do
      [:encrypt, :decrypt, :private_key!, :public_key,
        :other_public_key=].each do |m|

        expect(subject).to respond_to m

        expect { subject.send(m) }.to raise_error NotImplementedError
      end
    end
  end
end
