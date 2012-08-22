class AuditorUser < User
  include AuditorUserPermissions

  def lender
    AuditorUserLender.new
  end

  def lenders
    Lender.scoped
  end
end
