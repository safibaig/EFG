module CfeAdminPermissions
  def can_create?(resource)
    [
      CfeAdmin,
      CfeUser,
      LenderAdmin
    ].include?(resource)
  end

  def can_update?(resource)
    [
      CfeAdmin,
      CfeUser,
      LenderAdmin
    ].include?(resource)
  end

  def can_view?(resource)
    [
      CfeAdmin,
      CfeUser,
      LenderAdmin
    ].include?(resource)
  end
end
