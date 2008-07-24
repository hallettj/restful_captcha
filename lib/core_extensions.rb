module Enumerable
  def collect_with_index
    idx = 0
    collect{|elm| result = yield(elm, idx); idx = idx + 1; result}
  end
  alias map_with_index collect_with_index
end
