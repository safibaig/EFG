class User < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

  belongs_to :lender

  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"

  belongs_to :modified_by, class_name: "User", foreign_key: "modified_by_id"

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation

  # FIXME: lender users should require a lender so require lender_id when we
  # come to implementing roles
  validates_presence_of :first_name, :last_name

  def name
    "#{first_name} #{last_name}"
  end

end
