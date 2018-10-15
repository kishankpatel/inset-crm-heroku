class GoalsController < ApplicationController
	def index
		@period = @@period
		if @current_user.is_admin?
			@goals = @current_organization.goals.order("id desc")
			@goalsd = @current_organization.goals.group_by(&:user_id)
		else
			@goals = @current_user.goals
		end
		@goal = @goals.first
	end

	def goals_view
		@period = @@period
		if params[:user_id].present?
			@goal = @current_organization.goals.where("id=? AND user_id=?",params[:goal_id],params[:user_id]).first
			@goals = @current_organization.goals.where("user_id=?",params[:user_id])
		else
			@goal = @current_user.goals.where("id=?",params[:goal_id]).first
			@goals = @current_user.goals
		end
		render :partial => "goals"
	end

	def user_goals
		@period = @@period
		@goal = @current_organization.goals.where("user_id=?",params[:user_id]).first
		@goals = @current_organization.goals.where("user_id=?",params[:user_id])
		@goalsd = @current_organization.goals.group_by(&:user_id)
		render :partial => "goals"
	end

	def show
		@en = params[:id].gsub(" ",'+').gsub("-",'/')
		@dcrypt = AESCrypt.decrypt(@en, "keysalt")
		@user = User.where("email=?",@dcrypt).first
		@period = @@period
		params[:user_id]=@user.id
		@goal = @current_organization.goals.where("user_id=?",@user.id).first
		@goals = @current_organization.goals.where("user_id=?",@user.id)
		@goalsd = @current_organization.goals.group_by(&:user_id)
	end

	def goals_by_user
		@user = @current_organization.users.find_by_id params[:user_id]
		encrypt_user = AESCrypt.encrypt(@user.email, "keysalt").gsub("/",'-')
		redirect_to "/goals/" + encrypt_user
	end
end
