class HomeController < ApplicationController
	respond_to :html, :js

  	def show
  		if current_user
			@user_fb_token = current_user.oauth_token
			
			# abort current_user.inspect
			unless @user_fb_token.blank?
				@fb_friends = FbGraph::User.me(@user_fb_token).friends
				
				@fb_friends = @fb_friends.sort_by { |fb_frnd| fb_frnd.raw_attributes['name']}

				# abort @fb_friends.inspect
				@friendsHash = Hash.new()
				if @fb_friends
					@fb_friends.each do |frd|
						@friendsHash[frd.raw_attributes['id'].to_s] = frd.raw_attributes['name']
					end
				end
				# abort @friendsHash.inspect		
			end

			current_user.multi_friends = @friendsHash
			current_user.save

			@invitedFriends = Invitefriend.where(:user_id => current_user.id).pluck(:inviteid)
			if @invitedFriends
				@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
				# abort @invitedFriends.inspect
				@alreadyinvitedusers = User.where("id in (#{@invitedFriends})").pluck(:uid)
				# @alreadyinvitedusers = @alreadyinvitedusers.map(&:to_i)
			end
			# abort @alreadyinvitedusers.inspect
		end
  	end

  	def friendslist
  		if params[:searchFriend]
  			@friendsHash = current_user.multi_friends

  			@invitedFriends = Invitefriend.where(:user_id => current_user.id).pluck(:inviteid)
			if @invitedFriends
				@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
				@alreadyinvitedusers = User.where("id in (#{@invitedFriends})").pluck(:uid)
			end

			@friendsHash = @friendsHash.select{|key, hash| hash.downcase.include?(params[:searchFriend].downcase) }
  		end
  	end
end
