class RingBuffer

  def initialize(store, key:, capacity:)
    @store = store
    @key = key
    @capacity = capacity
  end

  def test
    @store.get(@key).tap do
      @store.set(@key, 1)
    end
  end

  def add(item)
  end

  def delete(item)
  end

  def includes?(item)
  end

  def clear
  end

end
