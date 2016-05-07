# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
:address => 'smtp.gmail.com',
:port => 587,
:user_name => "albertchang2010@gmail.com",
:password => "viralviral",
:authentication => :plain,
:enable_starttls_auto => true,
:openssl_verify_mode => 'none' 
}		
# ActionMailer::Base.smtp_settings = {
#   :address => "smtp.sendgrid.net",
#   :port => 25,
#   :domain => "sendgrid.com",
#   :authentication => :plain,
#   :user_name => "hetalkhunti",
#   :password => "hetal@123"
# }																																																																																																																															