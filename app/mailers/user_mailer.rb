class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'
  layout "mailer"

  def welcome_email(email, appUrl)
     # @user = user
     @url  = appUrl
     mail(to: email, subject: 'Facebook Invitation')
  end
end