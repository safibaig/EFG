class BasicSearch

  attr_reader :loans

  TextFields = %w(business_name trading_name company_registration state)

  SortByFields = %w(business_name trading_name amount postcode maturity_date updated_at modified_by_legacy_id)

  DefaultSortBy = "updated_at"

  AscDescOptions = %w(asc desc)

  def initialize(lender, search_params)
    @lender        = lender
    @search_params = search_params
    build
  end

  private

  def build
    @loans = @lender.loans

    # string fields
    TextFields.each do |field|
      @loans = @loans.where(field.to_sym => @search_params[field.to_sym]) if @search_params[field.to_sym].present?
    end

    # money fields
    if @search_params[:amount].present?
      amount = Money.parse(@search_params[:amount]).cents
      @loans = @loans.where(amount: amount)
    end

    # sort
    @loans = @loans.order(order_clause)
  end

  def order_clause
    sort_by_param = @search_params[:sort_by] || ""
    asc_desc_param = @search_params[:asc_desc] || ""

    sort_by = SortByFields.detect { |v| v == sort_by_param } || DefaultSortBy

    asc_or_desc = AscDescOptions.detect { |v| v == asc_desc_param } || "asc"

    "#{sort_by} #{asc_or_desc}"
  end

end
