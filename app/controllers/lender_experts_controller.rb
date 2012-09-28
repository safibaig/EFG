class LenderExpertsController < ApplicationController
  before_filter :verify_view_permission

  def index
    @lender = Lender.find(params[:lender_id])
    @experts = @lender.experts.includes(:user)
  end

  private
    def verify_view_permission
      enforce_view_permission(Expert)
    end
end
