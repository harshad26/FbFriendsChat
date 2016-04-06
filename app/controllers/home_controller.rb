class HomeController < ApplicationController
  def show
  		if current_user
			@user_fb_token = current_user.oauth_token
				
			unless @user_fb_token.blank?
				@fb_friends = FbGraph::User.me(@user_fb_token).friends
				
				@fb_friends = @fb_friends.sort_by { |fb_frnd| fb_frnd.raw_attributes['name']}
			end

			@invitedFriends = Invitefriend.where(:user_id => current_user.id).pluck(:inviteid)
			if @invitedFriends
				@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
				# abort @invitedFriends.inspect
				@invitedusers = User.where("id in (#{@invitedFriends})").pluck(:uid)
			end
			# abort @invitedusers.inspect
		end
  end
end
