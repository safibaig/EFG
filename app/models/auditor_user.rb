class AuditorUser < User
  include AuditorUserPermissions

  def lender
    AuditorUserLender.new
  end
end
