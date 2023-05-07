require 'leaky_bucket'
require 'timecop'

RSpec.describe LeakyBucket do

  let(:capacity) { 3 }
  let(:leak_rate) { 10 }
  let(:bucket) { described_class.new(redis, key: 'test_bucket', capacity: capacity, leak_rate: leak_rate) }

  describe '#fill' do
    subject { bucket.fill }

    it 'returns `nil` when the bucket was filled' do
      is_expected.to be_nil
    end

    it 'returns the amount of seconds before the bucket can be filled when full' do
      capacity.times { bucket.fill }
      is_expected.to be_within(1).of(leak_rate)
    end

    it 'can be filled when at capacity if enough time passes' do
      capacity.times { bucket.fill }
      Timecop.freeze(Time.now + leak_rate + 1) do
        is_expected.to be_nil
      end
    end
  end

  describe '#fill?' do
    subject { bucket.fill? }

    it 'returns true when the bucket was filled' do
      is_expected.to eq true
    end

    it 'returns false when the bucket could not be filled' do
      capacity.times { bucket.fill }
      is_expected.to eq false
    end
  end

  describe '#tip' do
    subject { bucket.tip }

    it 'empties the bucket when full' do
      capacity.times { bucket.fill }
      expect { subject }.to change(bucket, :fill?).from(false).to(true)
    end
  end

end
