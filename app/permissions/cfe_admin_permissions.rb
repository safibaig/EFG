module CfeAdminPermissions
  def can_create?(resource)
    [
      AuditorUser,
      CfeUser,
      Lender,
      LenderAdmin,
      LendingLimit,
      Phase,
      PremiumCollectorUser
    ].include?(resource)
  end

  def can_destroy?(resource)
    false
  end

  def can_update?(resource)
    [
      AuditorUser,
      CfeUser,
      Lender,
      LenderAdmin,
      LendingLimit,
      Phase,
      PremiumCollectorUser
    ].include?(resource)
  end

  def can_view?(resource)
    [
      AuditorUser,
      CfeUser,
      Expert,
      Lender,
      LenderAdmin,
      LendingLimit,
      Phase,
      PremiumCollectorUser
    ].include?(resource)
  end
end
