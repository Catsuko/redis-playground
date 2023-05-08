class BloomFilter

  def initialize(store, key:, capacity: 10_000)
    @store = store
    @key = key
    @capacity = capacity
  end

  def include?(item, &block)
    @store.getbit(@key, offset_for(item)).positive? && (
      !block_given? || !!block.call(item)
    )
  end

  def add(item)
    tap { @store.setbit(@key, offset_for(item), 1) }
  end

  def clear
    tap { @store.del(@key) }
  end

  def full?
    @store.bitcount(@key) >= @capacity
  end

private

  def offset_for(item)
    item.hash % @capacity
  end

end
