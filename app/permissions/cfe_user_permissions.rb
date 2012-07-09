module CfeUserPermissions
  def can_create?(resource)
    resource == Invoice
  end

  def can_update?(resource)
    false
  end

  def can_view?(resource)
    resource == Invoice
  end
end
