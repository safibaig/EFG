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

  def can_view?(resource)
    [
      CfeAdmin
    ].include?(resource)
  end
end
