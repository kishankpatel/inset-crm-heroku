class ConfirmationsController < Devise::ConfirmationsController
  def show
	super do |resource|
		# p resource.confirmed?
		if !resource.confirmed_at.present?
	    	if user_signed_in?	
	    		flash[:notice] = "Your account was already confirmed."
	    		redirect_to "/"
	    	else
	    		flash[:notice] = "Your account was already confirmed, please try signing in."
	    		redirect_to "/users/sign-in"
	    	end
	    	return
	    end
	end
  end
end
