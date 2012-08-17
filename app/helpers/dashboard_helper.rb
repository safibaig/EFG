module DashboardHelper

  def welcome_message(user)
    content = []
    if user.sign_in_count > 1
      content << content_tag(:h1, "Welcome back, #{current_user.first_name}")
      content << content_tag(:p, "Your last visit was #{distance_of_time_in_words_to_now(current_user.last_sign_in_at)} ago.")
    else
      content << content_tag(:h1, "Welcome #{current_user.first_name}")
    end
    content.join.html_safe
  end

end
