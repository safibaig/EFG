module LenderAdminPermissions
  def can_create?(resource)
    if resource == AskAnExpert
      !expert?
    elsif resource == AskCfe
      expert?
    else
      [
        Expert,
        LenderUser
      ].include?(resource)
    end
  end

  def can_destroy?(resource)
    resource == Expert
  end

  def can_update?(resource)
    [
      Expert,
      LenderUser
    ].include?(resource)
  end

  def can_view?(resource)
    [
      LenderUser
    ].include?(resource)
  end
end
