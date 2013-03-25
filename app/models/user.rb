require 'password_migration'

class User < ActiveRecord::Base
  include Canable::Cans

  MAXIMUM_LOGIN_ATTEMPTS = 3

  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  belongs_to :modified_by, class_name: "User", foreign_key: "modified_by_id"
  has_many :user_audits

  scope :non_experts, joins('LEFT JOIN experts ON experts.user_id = users.id').where('experts.id IS NULL')
  scope :order_by_username, order("username")
  scope :order_by_name, order('first_name, last_name')
  scope :with_email, where("email IS NOT NULL")

  before_validation :set_unique_username, on: :create

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation

  attr_protected :username

  validates_presence_of :first_name, :last_name, :username, :email

  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  devise :database_authenticatable, :recoverable, :trackable,
         :timeoutable, :authenticatable, :encryptable,        # devise core model extensions
         :strengthened, # in EFG/lib/devise/models/strengthened.rb
         :password_expirable # devise_security_extension

  after_create :update_stats

  def disable!
    update_attribute :disabled, true
  end

  def enable!
    update_attribute :disabled, false
  end

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
    if email.present?
      unlock!
      super
    end
  end

  def unlock!
    update_attributes(locked: false, failed_attempts:  0)
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
    last = last_name.gsub(/\W/, '')[0..3]
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

  def login_attempts_exceeded?
    self.failed_attempts > MAXIMUM_LOGIN_ATTEMPTS
  end

  def update_stats
    EFG.stats_collector.increment("users.created")
  end

  include PasswordMigration

end
