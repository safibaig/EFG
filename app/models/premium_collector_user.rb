class PremiumCollectorUser < User
  include PremiumCollectorUserPermissions

  def lender
    PremiumCollectorLender.new
  end
end
