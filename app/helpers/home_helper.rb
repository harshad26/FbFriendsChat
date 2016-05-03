module HomeHelper
	def to_rad(angle)
       angle * Math::PI / 180 
    end

	def dist(fbid)
		@me_latitude = current_user.latitude
		@me_longitude = current_user.longitude
		
		# @friendsHash.each do |item|
			if !@me_latitude.nil?
				@friendDetail = User.find_by_uid(fbid)

				# abort @friendDetail.latitude.inspect				
				if !@friendDetail.latitude.nil?
					@frd_latitude = @friendDetail.latitude
					@frd_longitude = @friendDetail.longitude
					
					radius = 6371
				    lat1 = self.to_rad(@me_latitude)
				    lat2 = to_rad(@frd_latitude)
				    lon1 = to_rad(@me_longitude)
				    lon2 = to_rad(@frd_longitude)
				    dLat = lat2-lat1  
				    dLon = lon2-lon1
				    a = Math::sin(dLat/2) * Math::sin(dLat/2) +
				       Math::cos(lat1) * Math::cos(lat2) * 
				       Math::sin(dLon/2) * Math::sin(dLon/2);
				    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a));
				    @d = (radius * c).round
				else
					@d = 'No found'
				end
			else
				@d = 'No found'
			end	
		# end	
		# @dt = []
		# @dt << @d 
		# abort @dt.inspect
	    return @d
    end

    def times(id)
    	@invitedFriendDate = Invitefriend.select("created_at").where("(user_id = #{current_user.id} and inviteid = #{id}) OR (user_id = #{id} and (inviteid = #{current_user.id} or invite_accepted = true))")
        @c = ((Time.now - @invitedFriendDate[0].created_at)/60 ).to_i
        # @c = ((Time.zone.now.localtime - @invitedFriendDate[0].created_at)/60 ).to_i
		return @c.to_s
	end

	def conversation_interlocutor(conversation)
    	conversation.recipient == current_user ? conversation.sender : conversation.recipient
  	end
end
