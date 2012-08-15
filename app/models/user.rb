class User < ActiveRecord::Base
  include Canable::Cans

  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  belongs_to :modified_by, class_name: "User", foreign_key: "modified_by_id"

  before_validation :set_unique_username, on: :create

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation

  validates_presence_of :first_name, :last_name, :username

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

  # Resets reset password token and sends new account notification email
  def send_new_account_notification
    generate_reset_password_token! if should_generate_reset_token?
    UserMailer.new_account_notification(self).deliver
  end

  private

  # Replicate how the existing system generates usernames.
  def generate_username
    last = last_name[0..3]
    number = '%04d' % Random.rand(10000)
    first = first_name[0]
    [last, number, first].join('')
  end

  # Password is required if it is being set, but not for new records
  def password_required?
    return false if new_record?
    super
  end

  def set_unique_username
    self.username ||= generate_username

    while User.where(username: username).exists? do
      self.username = generate_username
    end
  end
end
