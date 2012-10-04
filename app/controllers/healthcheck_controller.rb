class HealthcheckController < ActionController::Base
  def index
    # Check database connectivity
    Lender.count
    headers["Content-Type"] = "application/json"
    render :json => "{}"
  end
end
