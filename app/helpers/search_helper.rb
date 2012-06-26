module SearchHelper

  def search_results_count(loans)
    pluralize(loans.count, "result") + " found"
  end

  def basic_search_sorting_options
    [
      ['Business name', :business_name],
      ['Amount', :amount],
      ['Trading name', :trading_name],
      ['Postcode', :postcode],
      ['Maturity date', :maturity_date],
      ['Last modified date', :updated_at],
      ['Last modified by', :modified_by_legacy_id]
    ]
  end

end
