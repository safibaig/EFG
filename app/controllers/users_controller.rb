require 'memorable_password'

class UsersController < ApplicationController
  def index
    @users = current_lender.users
  end

  def show
    @user = current_lender.users.find(params[:id])
  end

  def new
    @user = current_lender.users.new
  end

  def create
    @user = current_lender.users.new(params[:user])
    password = MemorablePassword.generate
    @user.password = @user.password_confirmation = password

    if @user.save
      flash[:notice] = "The password has been set to: #{password}"
      redirect_to user_url(@user)
    else
      render :new
    end
  end

  def edit
    @user = current_lender.users.find(params[:id])
  end

  def update
    @user = current_lender.users.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to user_url(@user)
    else
      render :edit
    end
  end
end
