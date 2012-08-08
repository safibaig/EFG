class CfeAdmin < User
  include CfeAdminPermissions

  def lender
    CfeAdminLender.new
  end
end
