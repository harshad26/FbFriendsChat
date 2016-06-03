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

			# Get user Accepted friends UID
			acceptedFriends
			@alreadyAcceptedUsers = []
			if !@acceptedFriends.blank?
				@acceptedFriends = @acceptedFriends.map(&:inspect).join(', ')
				@alreadyAcceptedUsers = User.where("id in (#{@acceptedFriends})").pluck(:uid)
			end

            @dt = {}
            current_user.multi_friends.each do |k,v| 
            	dist = dist(k)
            	dist = (dist == 'No found') ? 99999 : dist
                @dt.merge!( k => dist)
            end
            @sortFriends = @dt.sort_by {|_k, val| val}
            @sortFriends += @sortFriends + @sortFriends + @sortFriends
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

		# Get user Accepted friends UID
		acceptedFriends
		@alreadyAcceptedUsers = []
		if !@acceptedFriends.blank?
			@acceptedFriends = @acceptedFriends.map(&:inspect).join(', ')
			@alreadyAcceptedUsers = User.where("id in (#{@acceptedFriends})").pluck(:uid)
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
			appUrl = root_url
			name = current_user.name
			UserMailer.welcome_email(params[:invite][:email],appUrl, name).deliver_later
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
		
		acceptedFriends

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

			# Get user Accepted friends UID
			acceptedFriends
			@alreadyAcceptedUsers = []
			if !@acceptedFriends.blank?
				@acceptedFriends = @acceptedFriends.map(&:inspect).join(', ')
				@alreadyAcceptedUsers = User.where("id in (#{@acceptedFriends})").pluck(:uid)
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

  	def status
      	session[:status] = params[:status]
      	render nothing: true
  	end

  	
end
