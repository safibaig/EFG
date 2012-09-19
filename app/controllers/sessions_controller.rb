class SessionsController < Devise::SessionsController

  after_filter :track_first_login, only: [:create]

  private

  def track_first_login
    if current_user && current_user.sign_in_count == 1
      current_user.user_audits.create!(
        function: UserAudit::INITIAL_LOGIN,
        modified_by: current_user,
        password: current_user.encrypted_password
      )
    end
  end

end
