class TextCompletion

  def initialize(store, key:)
    @store = store
    @key = key
  end

  def suggest(text, limit: 10)
    @store.zrange(@key, "[#{text}", "[#{text}\xff", limit: [0, limit], bylex: true)
  end

  def notice(terms)
    tap { @store.zadd(@key, 0, terms) }
  end
end
