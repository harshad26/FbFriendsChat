OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :facebook,ENV["FACEBOOK_APP_ID"],ENV["FACEBOOK_SECRET"], :scope => "user_friends"
  provider :facebook,"580494135459861","f3ff1a6a52b2774c179fe78736bfdbb7", :scope => "user_friends"
end