require 'active_model/model'

class AskCfe
  include ActiveModel::Model

  attr_accessor :message, :user

  validates_presence_of :user, strict: true
  validates_presence_of :message

  def deliver
    AskForHelpMailer.ask_cfe_email(self).deliver
  end

  def from
    user.email
  end

  def from_name
    user.name
  end

  def to
    ENV['ASK_CFE_SUPPORT_EMAIL']
  end
end
