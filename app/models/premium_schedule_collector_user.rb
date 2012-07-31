class PremiumScheduleCollectorUser < User
  include PremiumScheduleCollectorUserPermissions

  def lender
    PremiumScheduleCollectorLender.new
  end
end
