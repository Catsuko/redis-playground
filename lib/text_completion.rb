class TextCompletion

  def initialize(store, key:, purge_threshold: 10)
    @store = store
    @key = key
    @purge_threshold = purge_threshold.to_i
  end

  def suggest(text, limit: 10)
    return [] unless text.match?(/\w+/)

    @store.zrange(@key, "[#{text}", "[#{text}\xff", limit: [0, limit], bylex: true)
      .map { |suggestion| suggestion[/.*:/m].chop! }
      .compact
  end

  def notice(terms)
    tap do
      if terms.match?(/\w{3,}/)
        purge_old_suggestion
        processed_terms = terms.delete(':')
        processed_terms.strip!
        @store.eval(notice_term_script, [@key], [processed_terms])
      end
    end
  end

  def inspect
    "#{self.class}:#{@key}"
  end

private

  def purge_old_suggestion
    count, record = @store.multi do |r|
      r.zcard(@key)
      r.zrandmember(@key)
    end

    if count >= @purge_threshold
      suggestion, hits = *record.split(':')
      hits = hits.to_i

      @store.multi do |r|
        @store.zrem(@key, record)
        @store.zadd(@key, 0, "#{suggestion}:#{hits.pred}") if hits > 1
      end
    end
  end

  def notice_term_script
    @notice_term_script ||= %Q(
      local term = ARGV[1]
      local index_key = KEYS[1]
      local record = redis.call("zrange", index_key, "[" .. term .. ":", "[" .. term .. ":\xff", "BYLEX", "LIMIT", 0, 1)[1]
      local next_record = nil

      if record then
        redis.call("zrem", index_key, record)
        local counter = tonumber(string.match(record, ":(%d+)")) or 0
        next_record = term .. ":" .. counter + 1
      else
        next_record = term .. ":1"
      end

      redis.call("zadd", index_key, 0, next_record)
    )
  end

end
