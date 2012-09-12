class Search
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  ExactMatchFilters   = %w(state).freeze
  PartialMatchFilters = %w(business_name trading_name company_registration).freeze
  AllFilters          = (PartialMatchFilters + ExactMatchFilters).freeze
  SortableAttributes  = %w(business_name trading_name amount postcode maturity_date updated_at).freeze
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
      query = if ExactMatchFilters.include?(key)
        query.where(key => value)
      elsif PartialMatchFilters.include?(key)
        query.where("#{key} LIKE ?", "%#{value}%")
      end
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
      value = filter_blank_multi_select(value)
      memo[key] = value if value.present?
      memo
    end
  end

  def sanitize(options, value)
    options.detect {|option| option == value}
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_select(value)
    value.is_a?(Array) ? value.reject(&:blank?) : value
  end
end
