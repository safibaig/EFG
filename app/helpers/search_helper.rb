module SearchHelper
  def search_results_count(results)
    pluralize(results.count, "result") + " found"
  end
end
