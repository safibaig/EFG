class HealthcheckController < ActionController::Base
  def index
    # Check database connectivity
    Lender.count
    render json: {
      git_sha1: CURRENT_RELEASE_SHA,
      mailer_config: EFG::Application.config.action_mailer.default_url_options,
    }
  end
end
