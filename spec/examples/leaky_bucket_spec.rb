require 'leaky_bucket'

RSpec.describe LeakyBucket do

  let(:capacity) { 3 }
  let(:bucket) { described_class.new(redis, key: 'test_bucket', capacity: capacity) }

  describe '#full?' do
    subject { bucket.full? }

    it 'is not full when empty' do
      is_expected.to eq false      
    end
  end

  describe '#fill' do
    subject { bucket.fill }

    it 'returns the current size of the bucket' do
      is_expected.to eq 1
    end

    it 'fills the bucket when reaching capacity' do
      expect { capacity.times { bucket.fill } }.to change(bucket, :full?).from(false).to(true)
    end
  end

  describe '#remaining' do
    subject { bucket.remaining }

    it 'returns the capacity when the bucket is empty' do
      is_expected.to eq capacity
    end

    it 'returns the number of fills remaining when the bucket has been partially filled' do
      expect { bucket.fill }.to change(bucket, :remaining).from(capacity).to(capacity - 1)
    end
  end

  describe '#tip' do
    subject { bucket.tip }

    it 'empties the bucket' do
      capacity.times { bucket.fill }
      expect { subject }.to change(bucket, :remaining).from(0).to(capacity)
    end
  end

end
