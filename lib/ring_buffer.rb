class RingBuffer

  def initialize(store, key:, capacity:)
    @store = store
    @key = key
    @capacity = capacity
  end

  def add(item)
    @store.multi do |transaction|
      transaction.lpush(@key, item)
      transaction.ltrim(@key, 0, @capacity - 1)
    end
  end

  def delete(item)
  end

  def include?(item)
    !@store.lpos(@key, item, maxlen: @capacity).nil?
  end

  def clear
  end

end
