require 'ring_buffer'

RSpec.describe RingBuffer do

  let(:key) { described_class.name }
  let(:capacity) { 5 }
  let(:buffer) { described_class.new(redis, key: key, capacity: capacity) }

  describe '#add' do
    let(:item) { 1 }
    subject { buffer.add(item) }

    it 'returns buffer' do
      is_expected.to eq buffer
    end

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

    context 'when adding multiple items' do
      let(:first_item) { 1 }
      let(:second_item) { 2 }
      let(:capacity) { 3 }

      it 'accepts multiple arguments' do
        buffer.add(first_item, second_item)
        expect(buffer).to include(first_item)
        expect(buffer).to include(second_item)
      end

      it 'does not add more than the capacity' do
        items = (capacity * 2).times.to_a
        subject.add(*items)
        items.last(capacity).each do |n|
          expect(buffer).to include(n)
        end
        expect(buffer).not_to include(items.first)
      end
    end
  end

  describe '#delete' do
    let(:item) { 1 }
    subject { buffer.delete(item) }

    before do
      buffer.add(2)
      buffer.add(3)
    end

    it 'returns buffer' do
      is_expected.to eq buffer
    end

    it 'does not change buffer when item is not present' do
      expect { subject }.not_to change { buffer.include?(2) || buffer.include?(3) }
    end

    it 'removes item from buffer' do
      buffer.add(item)
      expect { subject }.to change { buffer.include?(item) }.from(true).to(false)
    end

    it 'removes all occurences of item from buffer' do
      capacity.times { buffer.add(item) }
      expect { subject }.to change { buffer.include?(item) }.from(true).to(false)
    end
  end

  describe '#peek' do
    before { buffer.add('a', 'b', 'c') }

    it 'returns first item when called without `n`' do
      expect(buffer.peek).to contain_exactly('a')
    end

    it 'returns multiple items' do
      expect(buffer.peek(2)).to contain_exactly('a', 'b')
    end

    it 'returns all items when `n` is at or above the capacity' do
      expect(buffer.peek(100)).to contain_exactly('a', 'b', 'c')
    end
  end

  describe '#clear' do
    subject { buffer.clear }

    it 'returns buffer' do
      is_expected.to eq buffer
    end

    it 'removes all items from the buffer' do
      items = [1, 2, 3]
      items.each { |item| buffer.add(item) }
      expect { subject }.to change { items.any? { |item| buffer.include?(item) } }.from(true).to(false)
    end
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
