class User < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

  belongs_to :lender

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation

  validates_presence_of :lender, strict: true
  validates_presence_of :first_name, :last_name

  def name
    "#{first_name} #{last_name}"
  end

end
