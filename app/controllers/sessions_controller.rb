class SessionsController < Devise::SessionsController

  after_filter :track_first_login, only: [:create]

end
