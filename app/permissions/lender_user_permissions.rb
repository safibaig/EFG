module LenderUserPermissions
  def can_create?(resource)
    return false if resource == Invoice
    true
  end

  def can_update?(resource)
    true
  end

  def can_view?(resource)
    !resource.is_a?(Invoice)
  end
end
