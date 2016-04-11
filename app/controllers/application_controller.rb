class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
   helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  private

  def login_user
  	unless current_user
  		redirect_to root_path
  		return false
  	end
  end

  # Already invited friends list ids in array
  def inviteFriends
    @invitedFriendsLists = Invitefriend.select("id, user_id, inviteid").where("user_id = #{current_user.id} OR (inviteid = #{current_user.id} and invite_accepted = true)")
    @invitedFriends = []
    if @invitedFriendsLists
      @invitedFriendsLists.each do |frd|
        if frd.user_id != current_user.id
          @invitedFriends << frd.user_id 
        else
          @invitedFriends << frd.inviteid
        end
      end
    else
    end
    return @invitedFriends
  end

end
