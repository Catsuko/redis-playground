# TODO: Look into rdoc or some alternative for documenting the redis classes
class RingBuffer

  def initialize(store, key:, capacity:)
    @store = store
    @key = key
    @capacity = capacity
  end

  # TODO: Implement peek -> get first `n` items from buffer as enumerator
  def peek(n = 1)
  end

  # TODO: Allow add to accept multiple items
  def add(item)
    tap do
      @store.multi do |transaction|
        transaction.lpush(@key, item)
        transaction.ltrim(@key, 0, @capacity - 1)
      end
    end
  end

  def delete(item)
    tap do
      @store.lrem(@key, 0, item)
    end
  end

  def include?(item)
    !@store.lpos(@key, item, maxlen: @capacity).nil?
  end

  def clear
    tap do
      @store.del(@key)
    end
  end

end
