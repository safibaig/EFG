class User < ActiveRecord::Base
  include Canable::Cans

  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  belongs_to :modified_by, class_name: "User", foreign_key: "modified_by_id"

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation

  validates_presence_of :first_name, :last_name

  def name
    "#{first_name} #{last_name}"
  end

  def has_password?
    encrypted_password.present?
  end

  # #reset_password_period_valid? defined in Devise::Models::Recoverable
  def password_reset_pending?
    reset_password_token.present? && reset_password_period_valid?
  end
end
