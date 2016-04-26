class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
   before_action :check_messages
   before_action :read_messages, :only => [:messages]
  
  include HomeHelper

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  private

  # Mark as read in table of logged in user
  def read_messages
    @useConversations = Message.where("user_id = (?)", current_user.id).pluck(:conversation_id)
    if @useConversations.count > 0
      @useConversations = @useConversations.uniq # Unique
      @useConversations = @useConversations.map(&:inspect).join(', ')
      @updatemsg = Message.where("user_id != (?) and conversation_id IN (?)", current_user.id, @useConversations).update_all(:mark_as_read => true)
      session[:mark_messages] = 0 # Mark as read messages
    end
  end

  def check_messages
    if (session[:mark_messages].nil? or session[:mark_messages] != 1) and current_user
      # @useConversations = Message.select("conversation_id").where("user_id = (?)", current_user.id).count
      # if @useConversations > 0
      #   @useConversations = Message.where("user_id = (?)", current_user.id).pluck(:conversation_id)
      #   @useConversations = @useConversations.uniq # Unique
      #   @useConversations = @useConversations.map(&:inspect).join(', ')
      #   @unreadMsg = Message.select("id").where("user_id != (?) and conversation_id IN (?) and mark_as_read = (?)", current_user.id, @useConversations, false).count
      #   if @unreadMsg > 0
      #     session[:mark_messages] = 1
      #   end
      # end
    end
  end

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

  def acceptedFriends
    @invitedAcceptedFrdsLists = Invitefriend.where("(user_id = #{current_user.id} OR inviteid = #{current_user.id}) and invite_accepted = true")
    @acceptedFriends = []
    if @invitedAcceptedFrdsLists.count > 0
      @invitedAcceptedFrdsLists.each do |frd|
        if frd.user_id != current_user.id
          @acceptedFriends << frd.user_id 
        else
          @acceptedFriends << frd.inviteid
        end
      end
    end
  end
end
