class PasswordsController < Devise::PasswordsController

  after_filter :track_first_login, only: [:update]

  after_filter :track_password_reset, only [:create]

  private

  def track_password_reset
    EFG.stats_collector.increment("users.password_reset_request")
  end

end
