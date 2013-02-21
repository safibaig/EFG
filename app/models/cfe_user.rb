class CfeUser < User
  include CfeUserPermissions

  def lender
    CfeUserLender.new
  end

  def lenders
    Lender.scoped
  end

  def lender_ids
    lenders.pluck(:id)
  end
end
