class CfeUser < User
  def lender
    CfeLender.new
  end
end
