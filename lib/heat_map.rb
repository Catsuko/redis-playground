class HeatMap

  def initialize(store)
    @store = store
  end

  def notice(area, item:)
    tap { @store.pfadd(area, item) }
  end

  def size_of(*area)
    @store.pfcount(area)
  end

  def clear(area)
    @store.del(area)
  end

end
