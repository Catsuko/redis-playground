# TODO: Look into rdoc or some alternative for documenting the redis classes
class RingBuffer

  def initialize(store, key:, capacity:)
    @store = store
    @key = key
    @capacity = capacity
  end

  def peek(n = 1, &block)
    items = @store.lrange(@key, 0, n.clamp(1, @capacity) - 1)
    items.each(&block)
  end

  def add(*items)
    tap do
      @store.multi do |transaction|
        transaction.lpush(@key, items.last(@capacity).reverse)
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
