class UserMailer < ApplicationMailer
	default from: 'notifications@example.com'
 
  def welcome_email(user)
     @user = user
     @url  = 'https://www.facebook.com/login'
     mail(to: @user, subject: 'Facebook Invitation')
  end
end