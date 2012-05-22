class User < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

  attr_accessible :name, :email, :password, :password_confirmation

  validates_presence_of :name
end
