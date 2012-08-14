module LenderAdminPermissions
  def can_create?(resource)
    [
      LenderUser
    ].include?(resource)
  end

  def can_update?(resource)
    [
      LenderUser
    ].include?(resource)
  end

  def can_view?(resource)
    [
      LenderUser
    ].include?(resource)
  end
end
