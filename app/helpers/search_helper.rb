module SearchHelper

  def search_results_count(loans)
    pluralize(loans.count, "result") + " found"
  end

end
