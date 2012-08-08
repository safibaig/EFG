module CfeAdminPermissions
  def can_create?(resource)
    resource == LenderAdmin
  end

  def can_update?(resource)
    resource == LenderAdmin
  end

  def can_view?(resource)
    resource == LenderAdmin
  end
end
