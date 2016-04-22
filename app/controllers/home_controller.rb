class HomeController < ApplicationController
	before_filter :login_user, :only => [:searchlist, :distance, :matchfriends]
	respond_to :html, :js
	include HomeHelper
	helper_method :dist
	 
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

            @dt = {}
            current_user.multi_friends.each do |k,v| 
            	dist = dist(k)
            	dist = (dist == 'No found') ? 99999 : dist
                @dt.merge!( k => dist)
            end
            @sortFriends = @dt.sort_by {|_k, val| val}
            
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
		@dt = {}
        current_user.multi_friends.each do |k,v| 
            dist = dist(k)
        	dist = (dist == 'No found') ? 99999 : dist
            @dt.merge!( k => dist)
        end

        @sortFriends = @dt.sort_by {|_k, val| val}
	end

    def update_location
	    current_user.update_attributes(:latitude => params[:lat], :longitude => params[:lon])
	    render nothing: true
    end

	def distance 
     
	end	

	def invite_mail_send
		if params[:invite] and !params[:invite][:email].blank?
			# puts "#{root_url} ----------- "
			appUrl = root_url
			UserMailer.welcome_email(params[:invite][:email],appUrl).deliver_later
			redirect_to invite_mail_path, :notice => "Successfully sent invitation."
		else 
			redirect_to request.referer, :notice => "Something went wrong. Please try again later."
		end
	end

	def messages
      	@conversations = Conversation.involving(current_user).order("created_at DESC")
	end 	

	# Match friends list
	def matchfriends
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

		@alreadyinvitedusers = []
		@dt = {}
		if !@acceptedFriends.blank?
			@acceptedFriends = @acceptedFriends.map(&:inspect).join(', ')
			@alreadyinvitedusers = User.where("id in (#{@acceptedFriends})")
			@alreadyinvitedusers.each do |v| 
                dist = dist(v.uid)
	        	dist = (dist == 'No found') ? 99999 : dist
	            @dt.merge!( v.id => dist)
            end
		end
    	
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

			@dt = {}
            @friendsHash.each do |k,v| 
                dist = dist(k)
	        	dist = (dist == 'No found') ? 99999 : dist
	            @dt.merge!( k => dist)
            end

            @sortFriends = @dt.sort_by {|_k, val| val}
  		end
  	end
end
