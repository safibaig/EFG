class AuditorUser < User
  include AuditorUserPermissions

  def lender
    AuditorUserLender.new
  end

  def lenders
    Lender.scoped
  end

  def lender_ids
    lenders.pluck(:id)
  end
end
