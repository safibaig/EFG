module PremiumCollectorUserPermissions
  def can_create?(resource)
    [
      AskCfe,
      PremiumScheduleReport,
      SupportRequest
    ].include?(resource)
  end

  def can_update?(resource)
    false
  end

  def can_view?(resource)
    false
  end
end
