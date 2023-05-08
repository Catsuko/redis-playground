require 'bloom_filter'

RSpec.describe BloomFilter do

  let(:capacity) { 10 }
  let(:bloom_filter) { described_class.new(redis, key: 'test_bloom', capacity: capacity) }

  describe '#include?' do
    let(:item) { 'dog' }

    context 'when item has not been added' do
      it 'returns false' do
        expect(bloom_filter).not_to include(item)
      end

      it 'does not yield' do
        expect { |b| bloom_filter.include?(item, &b) }.not_to yield_control
      end
    end

    context 'when item has been added' do
      before { bloom_filter.add(item) }

      it 'returns true when no block has been provided' do
        expect(bloom_filter).to include(item)
      end

      it 'yields item to block' do
        expect { |b| bloom_filter.include?(item, &b) }.to yield_with_args(item)
      end

      it 'block evaluation determines outcome when provided' do
        expect(bloom_filter.include?(item) { 'truthy' }).to eq true
        expect(bloom_filter.include?(item) { nil }).to eq false
      end
    end
  end

  describe '#add' do
    it 'returns the bloom filter' do
      expect(bloom_filter.add('cat')).to be bloom_filter
    end
  end

  describe '#clear' do
    it 'returns the bloom filter' do
      expect(bloom_filter.clear).to be bloom_filter
    end

    it 'clears all added items' do
      bloom_filter.add('dog')
      expect { bloom_filter.clear }.to change { bloom_filter.include?('dog') }.from(true).to(false)
    end
  end

  describe '#full?' do
    let(:capacity) { 1 }
    subject { bloom_filter.full? }

    it 'returns true when all hash values have been added' do
      bloom_filter.add('mouse')
      expect(bloom_filter).to be_full
    end

    it 'returns false when some hash values remain' do
      expect(bloom_filter).not_to be_full 
    end
  end

end
