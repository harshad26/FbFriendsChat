class UserController < ApplicationController
	before_filter :login_user

  	def invitefriend
	  	if params[:id]
		  	user = User.find_by_uid(params[:id])
		  	@invitefriend = Invitefriend.new(:user_id => current_user.id, :inviteid => user.id)
		  	if @invitefriend.save
		  		render :json => { :text => "1"}
		  	else
		  		render :json => { :text => "0"}
		  	end
		else
			render :json => { :text => "0"}
		end
	  	return
  	end
end
