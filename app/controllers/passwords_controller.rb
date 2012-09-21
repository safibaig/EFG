class PasswordsController < Devise::PasswordsController

  after_filter :track_first_login, only: [:update]

end
