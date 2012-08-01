class CfeUser < User
  include CfeUserPermissions

  def lender
    CfeLender.new
  end

  def lenders
    Lender.scoped
  end
end
