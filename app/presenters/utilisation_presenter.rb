class UtilisationPresenter

  def initialize(lender)
    @lending_limits = lender.lending_limits.where("allocation > 0").order("starts_on DESC")
  end

  def each_lending_limit
    @lending_limits.each_with_index do |lending_limit, index|
      yield LendingLimitUtilisationPresenter.new(lending_limit), index
    end
  end

  def has_allocations?
    @lending_limits.any?
  end

end
