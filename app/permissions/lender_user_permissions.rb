module LenderUserPermissions
  def can_create?(resource)
    resource != Invoice
  end

  def can_update?(resource)
    true
  end

  def can_view?(resource)
    resource != Invoice
  end
end
