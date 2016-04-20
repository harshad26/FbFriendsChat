class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  
  include HomeHelper

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

   

  private

  def getMinutes(created_at)
    @c = ((Time.now - created_at)/60 ).to_i
  end

  def login_user
  	unless current_user
  		redirect_to root_path
  		return false
  	end
  end

  # Already invited friends list ids in array
  def inviteFriends
    @invitedFriendsLists = Invitefriend.select("id, user_id, inviteid, invite_accepted, created_at").where("((user_id = #{current_user.id}) OR (inviteid = #{current_user.id} and invite_accepted = true)) and invite_timeout = false")
    @invitedFriends = []
    if @invitedFriendsLists
      @invitedFriendsLists.each do |frd|
        minutes = getMinutes(frd.created_at)
        if (minutes <= 120)
          
          if frd.user_id != current_user.id
            @invitedFriends << frd.user_id 
          else
            @invitedFriends << frd.inviteid
          end
           
        else
          @conv = Conversation.where("((sender_id = #{frd.user_id} and recipient_id = #{frd.inviteid}) OR (sender_id = #{frd.inviteid} and recipient_id = #{frd.user_id}))")
          @conv.destroy_all 
          frd.delete
        # elsif frd.invite_accepted == false
        #   frd.invite_timeout = true
        #   frd.save
        end
      end
    end
    return @invitedFriends
  end

end
