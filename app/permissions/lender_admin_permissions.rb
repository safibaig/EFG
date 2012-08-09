module LenderAdminPermissions
  def can_create?(resource)
    false
  end

  def can_update?(resource)
    false
  end

  def can_view?(resource)
    false
  end
end
