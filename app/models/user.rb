class User < ActiveRecord::Base
  include Canable::Cans

  MAXIMUM_LOGIN_ATTEMPTS = 3

  devise :database_authenticatable, :recoverable, :trackable, :timeoutable, :authenticatable

  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  belongs_to :modified_by, class_name: "User", foreign_key: "modified_by_id"

  before_validation :set_unique_username, on: :create

  before_save :reset_failed_attempts

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation

  validates_presence_of :first_name, :last_name, :username, :email

  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  scope :order_by_username, order("username")

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

  # Override Devise's default behaviour so that an email with a blank "To" is
  # not sent.
  def send_reset_password_instructions
    super if email.present?
  end

  # custom account locking adapted from Devise lockable
  # - if user successfully authenticates, let them sign in
  #   regardless of whether they are locked (controller filter prevents access to anything)
  # - if user does not successfully authenticate and is locked
  #   persist the login attempt failure and lock the account when limit is reached
  def valid_for_authentication?
    if super
      true
    else
      self.failed_attempts ||= 0
      self.failed_attempts += 1
      if login_attempts_exceeded? && !locked?
        self.locked = true
      end
      save(validate: false)
      false
    end
  end

  private

  # Replicate how the existing system generates usernames.
  def generate_username
    last = last_name[0..3]
    number = '%04d' % Random.rand(10000)
    first = first_name[0]
    [last, number, first].join('').downcase
  end

  # Password is required if it is being set, but not for new records
  def password_required?
    return false if new_record?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def set_unique_username
    self.username ||= generate_username

    while User.where(username: username).exists? do
      self.username = generate_username
    end
  end

  # if unlocking account, reset failed_attempts to 0
  def reset_failed_attempts
    return unless locked_changed?
    self.failed_attempts = 0 unless locked?
  end

  def login_attempts_exceeded?
    self.failed_attempts > MAXIMUM_LOGIN_ATTEMPTS
  end

end
