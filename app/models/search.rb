class Search
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  MoneyAttributes     = %w(amount_from amount_to).freeze
  DateAttributes      = %w(maturity_date_from maturity_date_to updated_at_from updated_at_to).freeze
  SortableAttributes  = %w(business_name trading_name amount postcode maturity_date updated_at).freeze

  ExactMatchFilters   = %w(state lending_limit_id reason_id modified_by_id).freeze
  PartialMatchFilters = %w(business_name trading_name company_registration postcode
                           generic1 generic2 generic3 generic4 generic5).freeze
  RangeFilters        = (MoneyAttributes + DateAttributes).freeze
  AllFilters          = (PartialMatchFilters + ExactMatchFilters + RangeFilters).freeze

  SortOrders          = {'Ascending' => 'ASC', 'Descending' => 'DESC'}.freeze
  DefaultSortBy       = 'updated_at'.freeze
  DefaultSortOrder    = 'DESC'.freeze

  def initialize(lender, attributes = {})
    @lender = lender
    parse_attributes(attributes)
  end

  attr_reader :lender, :attributes

  AllFilters.each do |filter|
    define_method(filter) do
      attributes[filter]
    end
  end

  def sort_by
    @sort_by || DefaultSortBy
  end

  def sort_order
    @sort_order || DefaultSortOrder
  end

  def results
    query = lender.loans

    attributes.each do |key, value|
      condition = case key
      when *ExactMatchFilters
        { key => value }
      when *PartialMatchFilters
        ["#{key} LIKE ?", "%#{value}%"]
      when *RangeFilters
        range_condition(key, value)
      end

      query = query.where(condition)
    end

    query = query.order("#{sort_by} #{sort_order}")
    query
  end

  def persisted?
    false
  end

  private
  def parse_attributes(attributes)
    attributes ||= {}
    @sort_by = sanitize(SortableAttributes, attributes.delete('sort_by'))
    @sort_order = sanitize(SortOrders.values, attributes.delete('sort_order'))
    @attributes = attributes.slice(*AllFilters).inject({}) do |memo, (key, value)|
      filter_value = format_filter_value(key, value)
      memo[key] = filter_value if filter_value.present?
      memo
    end
  end

  def sanitize(options, value)
    options.detect {|option| option == value}
  end

  def format_filter_value(key, value)
    return nil if value.blank?
    return value.reject(&:blank?) if value.is_a?(Array)
    return Money.parse(value) if MoneyAttributes.include?(key)
    return Date.parse(value) if DateAttributes.include?(key)
    return value
  end

  def range_condition(key, value)
    field    = key.gsub(/_from|_to/, '')
    operator = key.include?('_from') ? ">=" : "<="
    value    = value.is_a?(Money) ? value.cents : value
    ["#{field} #{operator} ?", value]
  end

end
