class HomeController < ApplicationController
  def show
  		if current_user
			@user_fb_token = current_user.oauth_token
				
			unless @user_fb_token.blank?

				@fb_friends = FbGraph::User.me(@user_fb_token).friends
				#abort @fb_friends.inspect
				@fb_friends = @fb_friends.sort_by { |fb_frnd| fb_frnd.raw_attributes['name']}
			end

			@invitedFriends = Invitefriend.where(:user_id => current_user.id).pluck(:inviteid)
			if @invitedFriends
				@invitedFriends = @invitedFriends.map(&:inspect).join(', ')
				# abort @invitedFriends.inspect
				#@invitedusers = User.where("id in (#{@invitedFriends})").pluck(:uid)
			end
			# abort @invitedusers.inspect
		end
  end

  def update_location
  	#abort params[:lat].inspect
    current_user.update_attributes(:latitude => params[:lat], :longitude => params[:lon])
    render nothing: true
  end

  def distance
    #abort current_user.latitude.inspect
    @me_latitude = current_user.latitude
    @me_longitude = current_user.longitude
    @user_fb_token = current_user.oauth_token
    @fb_friends = FbGraph::User.me(@user_fb_token).friends
   
     # fb_friend.each do |item|
     abort @fb_friends.inspect
    @friend_latitude = @fb_friend.latitude
    @friend_longitude = @fb_friend.longitude
    abort @fb_friend.inspect
      radius = 6371
	  lat1 = to_rad(@me_latitude)
	  lat2 = to_rad(@friend_latitude)
	  lon1 = to_rad(@me_longitude)
	  lon2 = to_rad(@friend_longitude)
	  dLat = lat2-lat1   
	  dLon = lon2-lon1

	  a = Math::sin(dLat/2) * Math::sin(dLat/2) +
	       Math::cos(lat1) * Math::cos(lat2) * 
	       Math::sin(dLon/2) * Math::sin(dLon/2);
	  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a));
	  @d = radius * c
      abort @d.inspect
  end	

  def to_rad angle
     angle * Math::PI / 180 
  end

end

