OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,"68150529157","4f60b22d0bffc2d32e08be47c107e2e1", :scope => "user_friends"
  # provider :facebook,ENV["FACEBOOK_APP_ID"],ENV["FACEBOOK_SECRET"], :scope => "user_friends"
end