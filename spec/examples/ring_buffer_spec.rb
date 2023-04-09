require 'ring_buffer'

RSpec.describe RingBuffer do

  let(:key) { described_class.name }
  let(:capacity) { 5 }
  let(:buffer) { described_class.new(redis, key: key, capacity: capacity) }

  describe '#add' do
  end

  describe '#delete' do
  end

  describe '#includes?' do
  end

  describe '#clear' do
  end

end
