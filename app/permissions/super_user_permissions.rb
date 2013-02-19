module SuperUserPermissions
  def can_create?(resource)
    [
      CfeAdmin
    ].include?(resource)
  end

  def can_destroy?(resource)
    false
  end

  def can_update?(resource)
    [
      CfeAdmin
    ].include?(resource)
  end

  def can_enable?(resource)
    can_update?(resource)
  end

  def can_disable?(resource)
    can_update?(resource)
  end

  def can_unlock?(resource)
    can_update?(resource)
  end

  def can_view?(resource)
    [
      CfeAdmin
    ].include?(resource)
  end
end
