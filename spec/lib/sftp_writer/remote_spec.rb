# frozen_string_literal: true

RSpec.describe SFTPWriter::Remote do
  describe '#close' do
    it 'should return if sftp has not started' do
      expect(described_class.new({}, logger: {}).close).to eq(nil)
    end
  end
end
