module UserHelper
  def polymorphic_user_path(user, action=nil)
    path_components = dynamically_nested_user(user)
    path_components.unshift(action) if action
    polymorphic_path path_components
  end

  private

  def dynamically_nested_user(user)
    components = [user]
    components.unshift(user.lender) if [LenderUser, LenderAdmin].include? user.class
    components
  end
end
