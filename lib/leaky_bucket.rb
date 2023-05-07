class LeakyBucket

  def initialize(store, key:, capacity:, leak_rate: 60)
    @store = store
    @key = key
    @capacity = capacity
    @leak_rate = leak_rate
  end

  def fill
    @store.eval(fill_script, [@key], [Time.now.to_i, @capacity, @leak_rate])&.to_i
  end

  def fill?
    fill.nil?
  end

  def tip
    @store.del(@key)
  end

private

  def fill_script
    %Q(
      local bucketkey = KEYS[1]
      local timestamp = tonumber(ARGV[1])
      local capacity = tonumber(ARGV[2])
      local rate = tonumber(ARGV[3])

      local bucketinfo = redis.call("hmget", bucketkey, "prevtimestamp", "count")
      local prevtimestamp = tonumber(bucketinfo[1]) or timestamp
      local fillcount = tonumber(bucketinfo[2]) or 0
      fillcount = math.max(0, fillcount - math.floor((timestamp - prevtimestamp) / rate))

      if fillcount < capacity then
        redis.call("hset", bucketkey, "prevtimestamp", timestamp, "count", fillcount + 1)
        return nil
      end

      return (prevtimestamp + rate) - timestamp
    )
  end

end
