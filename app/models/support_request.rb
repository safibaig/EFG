class SupportRequest

  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :message, :user

  validates_presence_of :message, :user

  def initialize(attributes = {})
    @user = attributes[:user]
    @message = attributes[:message]
  end

  def recipients
    if user.is_a?(LenderUser)
      user.lender.lender_admins.with_email.collect(&:email)
    elsif user.is_a?(LenderAdmin)
      CfeUser.with_email.collect(&:email)
    elsif user.is_a?(CfeUser)
      SuperUser.with_email.collect(&:email)
    end
  end

  def persisted?
    false
  end

end
