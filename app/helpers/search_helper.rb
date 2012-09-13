module SearchHelper
  def search_results_count(results)
    pluralize(results.count, "result") + " found"
  end

  def modified_by_options
    current_lender.lender_users.order_by_username.map { |user| [ user.username, user.id ] }
  end

  def search_sort_options
    Search::SortableAttributes.map do |attribute|
      [ I18n.t("sort_#{attribute}", scope: [:simple_form, :labels, :search]), attribute ]
    end
  end
end
