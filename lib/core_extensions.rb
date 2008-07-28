# Extends Enumerable with Enumerable#collect_with_index and
# Enumerable#map_with_index

module Enumerable

  # Has the same behavior as Enumerable#collect, except that the index
  # of each element is passed to the given block in addition to the
  # element itself.
  def collect_with_index  # :yields: element, index
    idx = 0
    collect{|elm| result = yield(elm, idx); idx = idx + 1; result}
  end

  alias map_with_index collect_with_index

end
