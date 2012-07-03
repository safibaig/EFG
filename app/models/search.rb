class Search
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  Filters = %w(business_name trading_name company_registration state).freeze
  SortableAttributes = %w(business_name trading_name amount postcode maturity_date updated_at).freeze
  SortOrders = {'Ascending' => 'ASC', 'Descending' => 'DESC'}.freeze
  DefaultSortBy = 'updated_at'.freeze
  DefaultSortOrder = 'DESC'.freeze

  def initialize(lender, attributes = {})
    @lender = lender
    parse_attributes(attributes)
  end

  attr_reader :lender, :attributes

  Filters.each do |filter|
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

    conditions = attributes.select {|key, value| Filters.include?(key) }
    query = query.where(conditions)

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
    @attributes = attributes.slice(*Filters).select {|key, value| value.present?}
  end

  def sanitize(options, value)
    options.detect {|option| option == value}
  end
end
