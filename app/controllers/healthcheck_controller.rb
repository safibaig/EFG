class HealthcheckController < ActionController::Base
  def index
    # Check database connectivity
    Lender.count
    render json: { git_sha1: CURRENT_RELEASE_SHA }
  end
end
