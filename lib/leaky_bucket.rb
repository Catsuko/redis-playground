# TODO: Put a hole in the bucket so it leaks ;D
class LeakyBucket

  def initialize(store, key:, capacity:)
    @store = store
    @key = key
    @capacity = capacity
  end

  def full?
    !remaining.positive?
  end

  def remaining
    @capacity - @store.get(@key).to_i
  end

  def fill
    @store.incr(@key)
  end

  def tip
    @store.del(@key)
  end

end
