module SearchHelper
  def search_results_count(results)
    pluralize(results.count, "result") + " found"
  end

  def modified_by_options
    current_lender.lender_users.order_by_username.map { |user| [ user.username, user.id ] }
  end
end
