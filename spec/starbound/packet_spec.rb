require 'stringio'

describe Nova::Starbound::Protocol::Packet do

  context 'building responses' do
    subject { described_class.build_response :nul, "hello", :packet_id => 1, :packet_type => 1 }

    its(:struct) { should be :response }
    its(:response_id) { should be 1 }
    its(:packet_response_id) { should be 1 }
    its(:response_type) { should be 1 }
    its(:type) { should be :nul }
    its(:body) { should eq "hello" }
    its(:size) { should be "hello".length }

    it "returns the number type if it can't find it" do
      packet = described_class.build_response :nul, "hello"

      packet[:packet_type] = 1043

      expect(packet.type).to be 1043
    end
  end

  it "sets up expectations" do
    packet = NovaHelper.build_packet

    expect {
      packet.expect(:echo)
    }.to raise_error(Nova::Starbound::UnacceptablePacketError)
  end

  it "responds to missing methods" do
    packet = NovaHelper.build_packet
    packet[:something] = 1

    expect(packet).to be_respond_to_missing :something
  end

  context 'builds from socket' do
    subject {
      str = StringIO.new "\x00\x0b\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00" + (" " * 24) + "hello world\x00"
      described_class.from_socket(str)
    }

    its(:struct) { should be :packet }
    its(:packet_id) { should be 1 }
    its(:type) { should be :nul }
    its(:nonce) { should be_empty }
    its(:body) { should eq "hello world" }

    it "raises error if it can't determine the struct type" do
      str = StringIO.new "\xff\x0b\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00" + (" " * 24) + "hello world\x00"

      expect {
        described_class.from_socket(str)
      }.to raise_error(Nova::Starbound::NoStructError)
    end
  end

end
