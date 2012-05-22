module ControllerHelpers
  def sign_in(user)
    request.env['warden'].stub :authenticate! => user
    controller.stub current_user: user
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include ControllerHelpers,   type: :controller
end
