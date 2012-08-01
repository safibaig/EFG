class PremiumScheduleReportsController < ApplicationController
  before_filter :verify_create_permission

  def new
    @premium_schedule_report = PremiumScheduleReport.new
    @premium_schedule_report.schedule_type = PremiumScheduleReport::SCHEDULE_TYPES.first
    @premium_schedule_report.loan_type = PremiumScheduleReport::LOAN_TYPES.first
    @premium_schedule_report.loan_scheme = PremiumScheduleReport::LOAN_SCHEMES.first
  end

  def create
    @premium_schedule_report = PremiumScheduleReport.new(params[:premium_schedule_report])

    if @premium_schedule_report.valid?
      # TODO
    else
      render :new
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(PremiumScheduleReport)
    end
end
