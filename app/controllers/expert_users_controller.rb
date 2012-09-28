class ExpertUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:index, :create]
  before_filter :verify_destroy_permission, only: [:destroy]

  def index
    @experts = current_lender.experts.includes(:user)
    @expert = current_lender.experts.new
    @users = current_lender.users.non_experts.with_email.order_by_name
  end

  def create
    user_id = params[:expert][:user_id]

    if user_id.present?
      @expert = current_lender.experts.new
      @expert.user = current_lender.users.find(user_id)
      @expert.save && AdminAudit.log(AdminAudit::LenderExpertAdded, @expert.user, current_user)
    end

    redirect_to expert_users_url
  end

  def destroy
    @expert = current_lender.experts.find(params[:id])
    @expert.destroy && AdminAudit.log(AdminAudit::LenderExpertRemoved, @expert.user, current_user)
    redirect_to expert_users_url
  end

  private
    def verify_create_permission
      enforce_create_permission(Expert)
    end

    def verify_destroy_permission
      enforce_destroy_permission(Expert)
    end
end
