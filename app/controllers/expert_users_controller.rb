class ExpertUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:create]
  before_filter :verify_destroy_permission, only: [:destroy]
  before_filter :verify_view_permission, only: [:index]

  def index
    @experts = current_lender.experts.includes(:user)
    @expert = current_lender.experts.new
    @users = current_lender.users
  end

  def create
    @expert = current_lender.experts.new
    @expert.user = current_lender.users.find(params[:expert][:user_id])
    @expert.save!
    redirect_to expert_users_url
  end

  def destroy
    @expert = current_lender.experts.find(params[:id])
    @expert.destroy
    redirect_to expert_users_url
  end

  private
    def verify_create_permission
      enforce_create_permission(Expert)
    end

    def verify_destroy_permission
      enforce_destroy_permission(Expert)
    end

    def verify_view_permission
      enforce_view_permission(Expert)
    end
end
