class TextCompletion

  def initialize(store, key:)
    @store = store
    @key = key
  end

  def suggest(text, limit: 10)
    @store.zrange(@key, "[#{text}", "[#{text}\xff", limit: [0, limit], bylex: true)
      .map { |suggestion| suggestion[/.*:/m].chop! }
      .compact
  end

  def notice(terms)
    tap do
      @store.eval(new_or_increment_script, [@key], [terms.delete(':')])
    end
  end

private

  def new_or_increment_script
    @notice_script ||= %q(
      local term = ARGV[1]
      local record = next(redis.call("zrange", KEYS[1], "[" .. term .. ":", "+", "BYLEX", "LIMIT", 0, 1))
      local next_record = nil

      if record then
        redis.call("zrem", KEYS[1], record)
        local counter = tonumber(string.match(record, ":(%d+)")) or 0
        next_record = term .. ":" .. counter + 1
      else
        next_record = term .. ":1"
      end


      redis.call("zadd", KEYS[1], 0, next_record)
    )
  end

end
