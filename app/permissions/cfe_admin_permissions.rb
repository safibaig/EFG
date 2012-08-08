module CfeAdminPermissions
  def can_create?(resource)
    [
      CfeAdmin,
      LenderAdmin
    ].include?(resource)
  end

  def can_update?(resource)
    [
      CfeAdmin,
      LenderAdmin
    ].include?(resource)
  end

  def can_view?(resource)
    [
      CfeAdmin,
      LenderAdmin
    ].include?(resource)
  end
end
