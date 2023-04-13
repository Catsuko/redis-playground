require 'ring_buffer'

RSpec.describe RingBuffer do

  let(:key) { described_class.name }
  let(:capacity) { 5 }
  let(:buffer) { described_class.new(redis, key: key, capacity: capacity) }

  describe '#add' do
    let(:item) { 1 }
    subject { buffer.add(item) }

    it 'adds the item to the buffer' do
      expect { subject }.to change { buffer.include?(item) }.from(false).to(true)
    end

    context 'when at capacity' do
      before { capacity.times { |n| buffer.add(n) } }

      it 'pushes an old item out of the buffer' do
        expect { subject }.to change { buffer.include?(0) }.from(true).to(false)
        larger_buffer = described_class.new(redis, key: key, capacity: capacity * 100)
        expect(larger_buffer).not_to include(0)
      end
    end
  end

  describe '#delete' do
  end

  describe '#clear' do
  end

  describe '#include?' do
    let(:item) { 1 }
    subject { buffer.include?(item) }

    it 'returns false when the item is in the list but beyond the capacity' do
      larger_buffer = described_class.new(redis, key: key, capacity: capacity + 1)
      larger_buffer.add(item)
      capacity.times { larger_buffer.add(item + 1) }
      is_expected.to be false
    end
  end

end
