module CfeAdminPermissions
  def can_create?(resource)
    [
      AuditorUser,
      CfeUser,
      Lender,
      LenderAdmin,
      LendingLimit,
      PremiumCollectorUser
    ].include?(resource)
  end

  def can_update?(resource)
    [
      AuditorUser,
      CfeUser,
      Lender,
      LenderAdmin,
      LendingLimit,
      PremiumCollectorUser
    ].include?(resource)
  end

  def can_view?(resource)
    [
      AuditorUser,
      CfeUser,
      Lender,
      LenderAdmin,
      LendingLimit,
      PremiumCollectorUser
    ].include?(resource)
  end
end
