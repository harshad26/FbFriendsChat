class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'
  layout "mailer"

  def welcome_email(email, appUrl, name)
     @name = name
     @url  = appUrl
     mail(to: email, subject: 'Facebook Invitation')
  end
end