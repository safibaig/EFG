class UsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :reset_password]
  before_filter :verify_view_permission, only: [:index, :show]
  before_filter :verify_enable_permission, only: [:enable]
  before_filter :verify_disable_permission, only: [:disable]
  before_filter :verify_unlock_permission, only: [:unlock]

  before_filter :find_user, only: [:show, :edit, :update, :reset_password, :unlock, :disable, :enable]

  private
  %w(create update view enable disable unlock).each do |action|
    define_method :"verify_#{action}_permission" do
      send :"enforce_#{action}_permission", user_class
    end
  end
end
