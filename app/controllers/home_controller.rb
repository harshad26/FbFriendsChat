class HomeController < ApplicationController
	before_filter :login_user, :only => [:searchlist, :distance, :matchfriends]
	respond_to :html, :js

	def show
		if current_user
			@user_fb_token = current_user.oauth_token
			@friendsHash = Hash.new()
			unless @user_fb_token.blank?
				@fb_friends = FbGraph::User.me(@user_fb_token).friends
				@fb_friends = @fb_friends.sort_by { |fb_frnd| fb_frnd.raw_attributes['name']}
				if @fb_friends
					@fb_friends.each do |frd|
						@friendsHash[frd.raw_attributes['id'].to_s] = frd.raw_attributes['name']
					end
				end
			end

			# Save frieds hash array into database - serialization
			current_user.multi_friends = @friendsHash
			current_user.save
			# Get current user invited friends
			inviteFriends
			@alreadyinvitedusers = []
			if !@invitedFriends.blank?
				@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
				@alreadyinvitedusers = User.where("id in (#{@invitedFriends})").pluck(:uid)
			end
		end
	end

	# Search page for friends
	def searchlist
		@friendsHash = current_user.multi_friends
		# Get current user invited friends
		inviteFriends
		@alreadyinvitedusers = []
		if !@invitedFriends.blank?
			@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
			@alreadyinvitedusers = User.where("id in (#{@invitedFriends})").pluck(:uid)
		end
	end

    def update_location
	    current_user.update_attributes(:latitude => params[:lat], :longitude => params[:lon])
	    render nothing: true
    end

	def distance
	end	

	# Match friends list
	def matchfriends
		inviteFriends
		@alreadyinvitedusers = []
		if !@invitedFriends.blank?
			@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
			@alreadyinvitedusers = User.where("id in (#{@invitedFriends})")
		end
		# abort @alreadyinvitedusers.inspect
	end

  	def friendslist
  		if params[:searchFriend]
  			@friendsHash = current_user.multi_friends

  			# Get current user invited friends
  			inviteFriends

  			@alreadyinvitedusers = []
			if !@invitedFriends.blank?
				@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
				@alreadyinvitedusers = User.where("id in (#{@invitedFriends})").pluck(:uid)
			end

			@friendsHash = @friendsHash.select{|key, hash| hash.downcase.include?(params[:searchFriend].downcase) }
  		end
  	end
end
