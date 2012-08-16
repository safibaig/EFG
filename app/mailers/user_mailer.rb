class UserMailer < ActionMailer::Base

  def new_account_notification(user)
    @user = user
    mail(to: user.email, subject: "Please login to your new EFG account")
  end

end
