module LenderUserPermissions
  def can_create?(resource)
    return false if [Invoice, RealisationStatement].include?(resource)
    true
  end

  def can_update?(resource)
    true
  end

  def can_view?(resource)
    return false if [Invoice, RealisationStatement].include?(resource)
    true
  end
end
