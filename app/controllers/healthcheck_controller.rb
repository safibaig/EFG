class HealthcheckController < ActionController::Base
  def index
    # Check database connectivity
    Lender.count
    render json: {}
  end
end
