class UserController < ApplicationController
	before_filter :login_user
	# after_action :chatConversation, :only => [:invitefriend]
	skip_before_action :verify_authenticity_token

	# Mark on friends
  	def invitefriend
	  	if params[:id]
		  	user = User.find_by_uid(params[:id])
		  	invitefriend = Invitefriend.where("(user_id = #{current_user.id} and inviteid = #{user.id}) OR (user_id = #{user.id} and inviteid = #{current_user.id})")
		  	if invitefriend.count > 0
		  		invitefriend = invitefriend[0]
		  		if invitefriend.inviteid == current_user.id
		  			invitefriend.invite_accepted = true
		  			chatConversation
		  		end
		  	else
		  		invitefriend = Invitefriend.new(:user_id => current_user.id, :inviteid => user.id)
		  	end
		  	if invitefriend.save
		  		render :json => { :text => "1"}
		  	else
		  		render :json => { :text => "0"}
		  	end
		else
			render :json => { :text => "0"}
		end
	  	return
  	end

  	private

  	def chatConversation
  		user = User.find_by_uid(params[:id])
	    @conversation = Conversation.create!(:sender_id => current_user.id, :recipient_id => user.id)
	    if @conversation
		    Message.create!(:conversation_id => @conversation.id, :body => "Hey", :user_id => current_user.id)
		    Message.create!(:conversation_id => @conversation.id, :body => "Hey", :user_id => user.id)
		end
  	end

end
