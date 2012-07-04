class CfeUser < User
  include CfeUserPermissions

  def lender
    CfeLender.new
  end
end
