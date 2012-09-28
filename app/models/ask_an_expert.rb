require 'active_model/model'

class AskAnExpert
  include ActiveModel::Model

  attr_accessor :expert_users, :message, :user

  validates_presence_of :user, strict: true
  validates_presence_of :message
  validate :validate_at_least_one_to_email

  def deliver
    AskForHelpMailer.ask_an_expert_email(self).deliver
  end

  def from
    user.email
  end

  def from_name
    user.name
  end

  def to
    expert_users.map(&:email).reject(&:blank?).uniq
  end

  private
    def validate_at_least_one_to_email
      errors.add(:expert_users, :must_have_at_least_one_email) if to.empty?
    end
end
