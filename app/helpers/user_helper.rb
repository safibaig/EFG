module UserHelper
  def polymorphic_user_path(action=nil, user)
    path_components = [user]
    path_components.unshift(user.lender) if [LenderUser, LenderAdmin].include? user.class
    path_components.unshift(action) if action
    polymorphic_path path_components
  end
end
