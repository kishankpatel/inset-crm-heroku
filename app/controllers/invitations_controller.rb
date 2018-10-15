class InvitationsController < Devise::InvitationsController
  def edit
  	@user=User.find_by_invitation_token(params[:invitation_token], false)
  	
  	 super
    
  end

  def update
  	@user=User.find_by_invitation_token(params[:user][:invitation_token], false)
  
  	 super
    
  end
end
