module ApplicationHelper
  def friendly_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def current_user_access_restricted?
    current_user.disabled? || current_user.locked?
  end
end
