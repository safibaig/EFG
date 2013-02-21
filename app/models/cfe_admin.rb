class CfeAdmin < User
  include CfeAdminPermissions

  def lender
    CfeAdminLender.new
  end

  def lenders
    Lender.scoped
  end

  def lender_ids
    lenders.pluck(:id)
  end
end
