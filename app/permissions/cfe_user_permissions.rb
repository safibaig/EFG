module CfeUserPermissions
  def can_create?(resource)
    [Invoice, RealisationStatement].include?(resource)
  end

  def can_update?(resource)
    false
  end

  def can_view?(resource)
    [Invoice, RealisationStatement].include?(resource)
  end
end
