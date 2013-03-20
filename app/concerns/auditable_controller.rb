module AuditableController
  def audit(event, object, &action)
    ActiveRecord::Base.transaction do
      success = action.call
      AdminAudit.log(event, object, current_user) if success
      success
    end
  end
end
