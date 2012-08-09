class CfeUser < User
  include CfeUserPermissions

  def lender
    CfeUserLender.new
  end
end
