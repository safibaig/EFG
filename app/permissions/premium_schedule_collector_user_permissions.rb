module PremiumScheduleCollectorUserPermissions
  def can_create?(resource)
    resource == PremiumScheduleReport
  end

  def can_update?(resource)
    false
  end

  def can_view?(resource)
    false
  end
end
