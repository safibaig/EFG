require 'active_model/model'

class AskCfe
  TO_EMAIL = ::EFG::Application.config.cfe_support_email

  include ActiveModel::Model

  attr_accessor :message, :user, :user_agent

  validates_presence_of :user, strict: true
  validates_presence_of :message

  def browser
    [user_agent.browser, user_agent.version].join(', ')
  end

  def deliver
    AskForHelpMailer.ask_cfe_email(self).deliver
  end

  def from
    user.email
  end

  def from_name
    user.name
  end

  def operating_system
    [user_agent.platform, user_agent.os].join(', ')
  end

  def to
    TO_EMAIL
  end
end
