class SettingsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  skip_before_filter :authenticate_user!, :only => [:unscribe_latest_blog]

  def index
    @title = "InSet CRM | Free CRM Tool | Settings"
    @description = "InSet CRM the free crm tool registered user’s settings pages to customize their profile, contact, task and other crm solutions."
  end

  def save_group
    if (!params[:name].nil? && !params[:name].blank? && params[:id].nil?)

      #role =Role.new(name: params[:name], organization: @current_user.organization)
      role =@current_organization.roles.new(name: params[:name])
      role.save!
      respond_to do |format|
        format.text { render text: role.id }
      end
    elsif (!params[:name].nil? && !params[:name].blank? && !params[:id].nil?)
      #role= Role.find(params[:id])
      role= @current_organization.roles.find_by_id(params[:id])
      role.update_attribute :name, params[:name]
      respond_to do |format|
        format.text { render text: "success" }
      end
    else
      respond_to do |format|
        format.text { render text: "Please enter name" }
      end
    end
  end

  def get_group
    if (!params[:sort].nil? && !params[:sort].blank? && !params[:order].nil? && !params[:order].blank?)
      #groups = @current_user.organization.roles.order(params[:sort] + " " +  params[:order]).all
      #groups = Role.where("organization_id	=?", @current_organization.id).order(params[:sort] + " " + params[:order])
      groups = @current_organization.roles.order(params[:sort] + " " + params[:order])
    else
      #groups = @current_user.organization.roles.all
      #groups = Role.where("organization_id	=?", @current_organization.id)
      groups = @current_organization.roles
    end
    respond_to do |format|
      #format.html
      format.json { render json: groups.to_json }
    end
  end

  def delete_group
    #group= Role.find(params[:id])
    group= @current_organization.roles.find_by_id(params[:id])
    group.destroy if group
    render :text => "success"
  end

  #update the priority as per organization
  def update_priority_org
    PriorityType.update_priority_name params[:hot], params[:warm], params[:cold], @current_organization.id
    render :partial => "priority"
  end

  #update the deal statuses as per organization
  def update_deal_status
    DealStatus.update_status params[:deal], params[:qualify], params[:not_qual], params[:won], params[:lost], params[:junk], @current_organization.id
    render :partial => "deal_status"
  end

  #update the priority as per organization
  def update_feed_keyword_org
    org = FeedKeyword.find_by_organization_id @current_organization.id
    if org.nil? || org.blank?
      og = FeedKeyword.new(feed_tags: params[:keywords], organization: @current_organization)
      og.save!
    else
      org.update_attribute :feed_tags, params[:keywords]
    end
    render :partial => "feeds"
  end

  # POST settings/add_lead_stage
  def add_lead_stage
    render(text: 'failed', status: :not_acceptable) && return if params[:name].blank?
    render(text: 'not_allowed', status: :not_acceptable) && return if params[:name].downcase.strip == 'won' || params[:name].downcase.strip == 'lost'
    deal_status = current_user.organization.deal_statuses.new({name: params[:name], color: params[:color]})
    last_status = current_user.organization.deal_statuses.order('original_id desc').first
    deal_status.original_id = last_status.present? ? last_status.original_id.to_i + 1 : 1
    deal_status.is_visible = params[:is_visible]
    deal_status.is_funnel_view = params[:is_funnel_view]
    if deal_status.save
      render partial: 'lead_stages', status: :ok
    else
      render text: 'success', status: :internal_server_error
    end
  end

  # POST settings/update_lead_stages
  def update_lead_stages
    begin
      selected_statges = @current_organization.deal_statuses.where('id IN (?)', params[:stages])
      unselected_statges = @current_organization.deal_statuses.where('id NOT IN (?)', params[:stages])
      unselected_statges.update_all({is_active: false, original_id: 0})
      selected_statges.each_with_index do |stage, index|
        stage.update_attributes({is_active: true, original_id: (index + 1)})
      end
      render text: 'success', status: :ok
    rescue
      render text: 'success', status: :internal_server_error
    end
  end

  def update_stage_sequence
    sorted_data = params[:sorted]
    deal_statuses = @current_organization.deal_statuses.where({is_active: true})
    deal_statuses.each do |deal_status|
      deal_status.original_id = sorted_data[deal_status.name]
      deal_status.save
    end
    render nothing: true, status: :ok
  end
  def update_stage_sequence_in_setting
    sorted_data = params[:sorted]
    deal_statuses = @current_organization.deal_statuses.where("name NOT IN (?) AND is_active=?", ["Won","Lost"],true)
    deal_statuses.each do |deal_status|
      deal_status.original_id = sorted_data[deal_status.name]
      deal_status.save
    end
    render partial: 'sort_lead_status', status: :ok
  end


  def update_widget_org
    #Parameters: {"chart"=>"1", "activity"=>"1", "feeds"=>"1", "tasks"=>"1", "page"=>"widget"}
    puts "------------------------ update_widget_org"
    ##FIXME AMT
    org = Widget.find_by_organization_id_and_user_id @current_organization.id, @current_user.id
    if params[:page] == "widget"
      if org.nil? || org.blank?
        og = Widget.new(chart: params[:chart], activities: params[:activity], :summary => params[:summary], :usage => params[:usage], tasks: params[:tasks], organization_id: @current_organization.id, user: @current_user)
        og.save!
      else
        org.update_attributes :chart => params[:chart], :activities => params[:activity], :summary => params[:summary], :usage => params[:usage], :tasks => params[:tasks]
      end
      render :partial => "widgets"
    elsif params[:page] == "chart"
      if org.nil? || org.blank?
        og = Widget.new(line_chart: params[:linechart], pie_chart: params[:piechart], column_chart: params[:columnchart], statistics_chart: params[:statisticschart], organization_id: @current_organization.id, user: @current_user)
        og.save!
      else
        org.update_attributes :line_chart => params[:linechart], :pie_chart => params[:piechart], column_chart: params[:columnchart], statistics_chart: params[:statisticschart]
      end
      render :partial => "chart"
    end

  end

  def create_new_source
    source= Source.new
    source.organization = @current_organization
    source.name = params[:value]
    if source.save
      render json: {id: source.id, name: source.name}
    else
      render :text => "exists"
    end
  end

  def save_source
    source= Source.new
    source.organization = @current_organization
    source.name = params[:value]
    if source.save
      #source= Source.create(:organization=>current_user.organization,:name=>params[:value])
      #source= Source.create(:organization=>current_user.organization,:name=>params[:source][:name])
      if params[:from] == "editdeal" && !params[:pk].nil?
        #deal_source = DealSource.where(:deal_id => params[:pk].to_i).first
        deal_source = @current_organization.deal_sources.where(:deal_id => params[:pk].to_i).first
        if deal_source.present?
          deal_source.update_column :source_id, source.id
        else
          DealSource.create(:organization => @current_organization, :deal_id => params[:pk].to_i, :source_id => source.id)
        end
      end
      flash[:notice] = "Source has been added successfully."
      render :text => source.id.to_s + "-" + source.name
    else
      msgs=source.errors.messages
      render :text => "exists"
    end
  end

  def save_industry
    industry= Industry.new
    industry.organization = @current_organization
    industry.name = params[:value]
    #industry= Industry.create(:organization=>current_user.organization,:name=>params[:value])
    #industry= Industry.create(:organization=>current_user.organization,:name=>params[:industry][:name])
    if industry.save
      #source= Source.create(:organization=>current_user.organization,:name=>params[:value])
      #source= Source.create(:organization=>current_user.organization,:name=>params[:source][:name])
      if params[:from] == "editdeal" && !params[:pk].nil?
        #deal = DealIndustry.where(:deal_id => params[:pk].to_i).first
        deal = @current_organization.deal_industries.where(:deal_id => params[:pk].to_i).first
        if deal.present?
          deal.update_column :industry_id, industry.id
        else
          DealIndustry.create(:organization => @current_organization, :deal_id => params[:pk].to_i, :industry_id => industry.id)
        end
      end
      flash[:notice] = "Industry has been added successfully."
      render :text => industry.id.to_s + "-" + industry.name
    else
      msgs=industry.errors.messages
      render :text => "exists"
    end
  end

  def save_label
    label= UserLabel.create(:organization => @current_organization, :name => params[:user_label][:name], :color => params[:user_label][:color], :user => @current_user)
    flash[:bosuccess] = "A new Label has been added. You can use it right away! You're a fast learner buddy."
    render :text => label.id.to_s + "-" + label.name
  end

  def save_user_label
    if (!params[:name].nil? && !params[:name].blank? && !params[:color].nil? && !params[:color].blank? && params[:id].nil?)

      label= UserLabel.create(:organization => @current_organization, :name => params[:name], :color => params[:color], :user => @current_user)
      respond_to do |format|
        format.text { render text: label.id }
      end
    elsif (!params[:name].nil? && !params[:name].blank? && !params[:color].nil? && !params[:color].blank? && !params[:id].nil?)
      label= UserLabel.find(params[:id])
      label.update_attributes(:name => params[:name],
                              :color => params[:color])
      respond_to do |format|
        format.text { render text: 'success' }
      end
    else
      respond_to do |format|
        format.text { render text: 'Please enter name and color' }
      end
    end


    #render :text=> label.id.to_s + "-" + label.name
  end

  def get_user_label
    if (!params[:sort].nil? && !params[:sort].blank? && !params[:order].nil? && !params[:order].blank?)
      labels = @current_user.user_labels.order(params[:sort] + " " + params[:order]).all
    else
      labels = @current_user.user_labels if current_user.present? && current_user.user_labels.present?
    end
    respond_to do |format|
      #format.html
      format.json { render json: labels.to_json }
    end
  end

  def update_user_label

  end

  def edit_source
    #source= Source.find(params[:source_id])
    source= @current_organization.sources.find_by_id(params[:source_id])
    #msgs=source.errors.messages
    source.update_attributes(:name => params[:name])
    if source.errors.messages.present?
      msgs=source.errors.messages
    else
      msgs='success'
    end
    render :text => msgs
    #respond_to do |format|
    #format.text {render text: "success"}
    #end
  end

  def edit_industry
    #ind= Industry.find(params[:industry_id])
    ind= @current_organization.industries.find_by_id(params[:industry_id])
    ind.update_attributes(:name => params[:name])

    if ind.errors.messages.present?
      msgs=ind.errors.messages
    else
      msgs='success'
    end
    render :text => msgs
    #respond_to do |format|
    #format.text {render text: "success"}
    #end
  end

  def update_org_settings
    org = Organization.find current_user.organization.id

    org.update_attributes(params[:organization])
    current_user.update_column :time_zone, params[:organization][:time_zone]
    flash[:notice] = 'Updated Successfully'
    redirect_to request.referrer
  end

  def delete_label
    label= UserLabel.find(params[:id])
    label.destroy
    render :text => 'success'
  end

  def update_notification
    email_notify = EmailNotification.find_by_user_id @current_user.id
    if email_notify.nil? || email_notify.blank?
      email = EmailNotification.new(user_id: @current_user.id, due_task: params[:tasks], task_assign: params[:task_assign], deal_assign: params[:deal_assign], donot_send: params[:donot_send])
      email.save!
    else
      email_notify.update_attributes :user_id => @current_user.id, :due_task => params[:tasks], :task_assign => params[:task_assign], :deal_assign => params[:deal_assign], :donot_send => params[:donot_send]
    end
    render :partial => 'email_notification'
  end

  def get_task_outcome_label
    t_out = @current_organization.task_outcomes
    respond_to do |format|
      format.json { render json: t_out.to_json }
    end
  end

  def save_task_outcome_label    
    if params[:name].present? && params[:task_type_name].present? && !params[:id].present?  
      @task_type = TaskType.where(name: params[:task_type_name], organization_id: @current_organization).first_or_create
      t_out= TaskOutcome.create(:organization_id =>@current_organization.id,:name => params[:name], :task_out_type => params[:task_type_name], :task_duration => params[:task_duration_name])
      respond_to do |format|
        format.text { render text: t_out.id }
      end
    elsif params[:name].present? && params[:task_type_name].present? && params[:id].present?
      @task_type = TaskType.where(name: params[:task_type_name], organization_id: @current_organization).first_or_create
      taskoutcome= TaskOutcome.find(params[:id])
      taskoutcome.update_attributes(:name => params[:name], :task_out_type => params[:task_type_name], :task_duration => params[:task_duration_name])
      respond_to do |format|
        format.text { render text: 'success' }
      end
    else
      respond_to do |format|
        format.text { render text: 'Please enter task outcome name, type and duration' }
      end
    end
  end


  def delete_taskoutcome
    taskoutcome= TaskOutcome.find(params[:id])
    taskoutcome.destroy
    render :text => 'success'
  end

  def fetch_pages
    @apis = @current_organization.api_integrations
    case params[:tab]
      
      when 'lead_stages'
        render :partial => 'lead_stages'
      when 'tasks_type'
        render :partial => 'tasks_type'
      when 'sns'
        render :partial => 'sns'
      when 'widgets'
        render :partial => 'widgets'

      when 'chart'
        render :partial => 'chart'

      when 'group'
        render :partial => 'groups'
      when 'email_setup'
        render :partial => 'email_setup'

      when 'org'
        render :partial => 'org'

      when 'user_designations'
        render :partial => 'user_designations'

      when 'user_hourly_billables'
        render :partial => 'user_hourly_billables'

      when 'task_outcome'
        render :partial => 'task_outcome'

      when 'api_integration'
        render :partial => "api_integration"

      when 'priority'
        render :partial => 'priority'

      when 'default_currency'
        render :partial => 'default_currency'

      when 'deal'
        render :partial => 'deal_status'

      when 'user_label'
        render :partial => 'user_label'

      when 'api_token'
        render :partial => 'api_token'

      when 'weekly_digest'
        render :partial => 'weekly_digest'
      when 'job_types'
        render :partial => 'project_jobs/job_types'
      when 'job_groups'
        render :partial => 'project_jobs/job_groups'
      when 'project_task_type'
        render :partial => 'projects/project_task_type'
      when 'lost_reasons'
        render :partial => 'lost_reasons'
      when 'goals'
        # begin
          @period = @@period 
          @goals = @current_organization.goals.order("id desc")
          @goalsd = @current_organization.goals.group_by(&:user_id)
          @cur = @@currencies
          render :partial => 'goals/admin_goals'  
        # rescue => ex
        #   p ex.backtrace
        #   p ex.message
        #   render :text => ex.backtrace
        # end
      when 'project_stages'
        render :partial => 'project_stages'
      else
        render nothing: true, status: :no_content
    end

  end
  
  #save goals
  def save_goal
   @goal = Goal.create(:organization_id=>@current_organization.id,:user_id => params[:user_id],:deal_stage_id => params[:stage],:period => params[:period],:quantity_deal => params[:expected],:goal_type=>params[:goal_type], :currency=>params[:currency])
   flash[:notice] = "Goal saved successfully"
   @goals = @current_organization.goals.order("id desc")
   # render partial: 'goal_all', status: :ok
   @period = @@period 
   @goalsd = @current_organization.goals.group_by(&:user_id)
   @cur = @@currencies
   render :partial => 'goals/goals_data', status: :ok
   
   #redirect_to request.referrer
  end
  
  #delete goal
  def delete_goal
    @goal = Goal.find params[:gid]
    @goal.delete
    #flash[:notice] = "Goal has been deleted successfully"
    @goals = @current_organization.goals.order("id desc")
    # render partial: 'goal_all', status: :ok
    @period = @@period 
    @goalsd = @current_organization.goals.group_by(&:user_id)
    @cur = @@currencies
    render :partial => 'goals/goals_data', status: :ok
  end
  
  def show_edit_goal
    @goal = Goal.find params[:goal_id]
    @period = @@period 
    @cur = @@currencies
    render partial: 'edit_goal', status: :ok
  end
  
  def edit_goal
   @goal = Goal.find params[:goal_id]
   if @goal.goal_type == "value of deals won"
     @goal.update_attributes(:user_id => params[:user_id],:period => params[:period], :quantity_deal => params[:qnt],:currency => params[:cur])
   end
   if @goal.goal_type == "quantity of deals won"
     @goal.update_attributes(:user_id => params[:user_id],:period => params[:period], :quantity_deal => params[:qnt])
   end
   if @goal.goal_type == "value of deals"
    @goal.update_attributes(:user_id => params[:user_id],:deal_stage_id => params[:stage_id],:period => params[:period], :quantity_deal => params[:qnt],:currency => params[:cur])
   end
   if @goal.goal_type == "quantity of deals"
    @goal.update_attributes(:user_id => params[:user_id],:deal_stage_id => params[:stage_id],:period => params[:period], :quantity_deal => params[:qnt])
   end
   #render partial: 'goal_all', status: :ok
   @goals = @current_organization.goals.order("id desc")
   @period = @@period 
   @goalsd = @current_organization.goals.group_by(&:user_id)
   @cur = @@currencies
   render :partial => 'goals/goals_data', status: :ok
  end
  
  def update_weekly_digest
    if request.xhr?
      #user_preference = UserPreference.find_by_user_id params[:user_id]
      user_preference = @current_organization.user_preferences.find_by_user_id params[:user_id]

      if params[:weekly_digest] == '0'
        user_preference.update_attributes({:weekly_digest => params[:weekly_digest]}) if user_preference
      else
        user_preference.update_attributes({:digest_mail_frequency => params[:frequency_digest], :weekly_digest => params[:weekly_digest]}) if user_preference
      end
      render :partial => 'weekly_digest'
    else
      crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
      decrypted_user_id = crypt.decrypt_and_verify(params[:user_id])
      user_preference = UserPreference.find_by_user_id decrypted_user_id
      user_preference.update_attributes :weekly_digest => 0
      flash[:notice] = 'Weekly digest updated successfully.'
      redirect_to root_path
    end
  end

  def unscribe_latest_blog
    if request.xhr?
      #ind_cont = IndividualContact.find params[:contact_id]
      ind_cont = @current_organization.individual_contacts.find_by_id params[:contact_id]
      ind_cont.update_attributes :subscribe_blog_mail => params[:latest_blog]
      render :partial => 'latest_blog_notification'
    else
      crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
      decrypted_user_id = crypt.decrypt_and_verify(params[:contact_id])
      #ind_cont = IndividualContact.find decrypted_user_id
      ind_cont = @current_organization.individual_contacts.find_by_id decrypted_user_id
      ind_cont.update_attributes({:subscribe_blog_mail => 0})
      flash[:notice] = "You'll no longer receive emails about Andolasoft Blog updates."
      redirect_to root_path
    end
  end
  def edit_status
    #@lead_status = DealStatus.find(params[:id])
    @lead_status = @current_organization.deal_statuses.find_by_id(params[:id])
    $lead_status_id = @lead_status.id
    render :partial => "edit_lead_status"
  end
  def delete_stage
    p request.xhr?
    # @stage = DealStatus.find(params[:id])
    @stage = @current_organization.deal_statuses.find_by_id(params[:id])
    if @stage.destroy
      render text: "Success", status: :ok
    else
      render text: "Fail", status: 406
    end
    # @stage.destroy
    # respond_to do |format|
    #   format.js
    # end
  end
  def update_current_lead_status
    # @lead_status = DealStatus.find(params[:id])
    if params[:name].downcase.strip == 'won' || params[:name].downcase.strip == 'lost'
      render json: {text: "not_allowed"}
    else
      @lead_status = @current_organization.deal_statuses.find_by_id(params[:id])
      # For this time we are not saving color
      # if @lead_status.update_attributes(:name => params[:name], :is_visible => params[:is_visible], :color => params[:color], :is_funnel_view => params[:is_funnel_view])
      #   render json: {name: @lead_status.name, color: @lead_status.color, is_visible: @lead_status.is_visible, is_funnel_view: @lead_status.is_funnel_view }, status: :ok
      # else
      if @lead_status.update_attributes(:name => params[:name], :is_visible => params[:is_visible], :is_funnel_view => params[:is_funnel_view])
        render json: {name: @lead_status.name, is_visible: @lead_status.is_visible, is_funnel_view: @lead_status.is_funnel_view }, status: :ok
      else
        render text: 'Fail', status: 406
      end
    end
  end
  def delete_task_type
    # @task_type = TaskType.find(params[:id])
    @task_type = @current_organization.task_types.find_by_id(params[:id])
    if @task_type.destroy
      render text: "Success", status: :ok
    else
      render text: "Fail", status: 406
    end
  end

  def update_task_type
    # @task_type = TaskType.find(params[:id])
    @task_type = @current_organization.task_types.find_by_id(params[:id])
    p @task_type
    if @task_type.update_attributes("name" => params[:name])
      render text:  @task_type.name, status: :ok
    else
      render text: "Fail", status: 406
    end
  end
  def add_task_type
    @new_task_type = TaskType.new
    @new_task_type.name = params[:name]
    @new_task_type.organization_id = current_user.organization.id
    if @new_task_type.save
      render :partial => 'listing_task_type'
    else
      render text: "Fail", status: 406
    end
  end

  def add_lost_reason
    @lost_reason = LostReason.new
    @lost_reason.reason = params[:reason]
    @lost_reason.organization_id = current_user.organization.id
    if @lost_reason.save
      render :partial => 'listing_lost_reasons'
    else
      render text: "Fail", status: 406
    end
  end 

  def update_lost_reason
    @lost_reason = @current_organization.lost_reasons.find_by_id(params[:id])
    if @lost_reason.update_attributes("reason" => params[:reason])
      render text: @lost_reason.reason, status: :ok
    else
      render text: "Fail", status: 406
    end
  end

  def delete_lost_reason
    @lost_reason = @current_organization.lost_reasons.find_by_id(params[:id])
    if @lost_reason.destroy
      render text: "Success", status: :ok
    else
      render text: "Fail", status: 406
    end
  end

  def find_code_for_javascript
    render :partial => 'code_for_javascript'
  end

  def enable_api
    api_integration = ApiIntegration.new(params[:api_integration])
    api_integration.organization = @current_organization
    if api_integration.save
      render json: {message: 'Success', id: api_integration.id}, status: 200
    else
      render json: {message: 'Fail'}, status: 500
    end
  end

  def disable_api
    api_integration = ApiIntegration.find(params[:id])
    if api_integration.destroy
      render json: {message: 'Success'}, status: 200
    else
      render json: {message: 'Fail'}, status: 500
    end
  end

  def reset_email_setting
    @current_user.update_attribute :smtp_config, ""
    @current_user.smtp_configuration.destroy
    render text:"success"
  end

  def update_organization_currency
    @current_organization.update_attribute :default_currency, params[:currency]
    render text:"success"
  end
  # POST settings/add_project_stage
  def add_project_stage
    render(text: 'failed', status: :not_acceptable) && return if params[:name].blank?
    
    project_stage = current_user.organization.project_stages.new({name: params[:name]})
    last_status = current_user.organization.project_stages.order('position desc').first
    project_stage.position = last_status.present? ? last_status.position.to_i + 1 : 1
    project_stage.is_active = true
    if project_stage.save
      render partial: 'project_stages', status: :ok
    else
      render text: 'success', status: :internal_server_error
    end
  end

  # POST settings/update_lead_stages
  def update_lead_stages
    begin
      selected_statges = @current_organization.project_stages.where('id IN (?)', params[:stages])
      unselected_statges = @current_organization.project_stages.where('id NOT IN (?)', params[:stages])
      unselected_statges.update_all({is_active: false, position: 0})
      selected_statges.each_with_index do |stage, index|
        stage.update_attributes({is_active: true, position: (index + 1)})
      end
      render text: 'success', status: :ok
    rescue
      render text: 'success', status: :internal_server_error
    end
  end
  def update_current_project_status
    @project_stage = @current_organization.project_stages.find_by_id(params[:id])
    if @project_stage.update_attributes(:name => params[:name])
      render json: {name: @project_stage.name}, status: :ok
    else
      render text: 'Fail', status: 406
    end
    
  end
  def update_project_stage_sequence_in_setting
    sorted_data = params[:sorted]
    project_stages = @current_organization.project_stages.where(" is_active=?",true)
    project_stages.each do |project_stage|
      project_stage.position = sorted_data[project_stage.name]
      project_stage.save
    end
    render partial: 'sort_project_status', status: :ok
  end
  def delete_project_stage
    @stage = @current_organization.project_stages.find_by_id(params[:id])
    if(@stage.projects.count == 0 &&  @stage.destroy)
      render text: "Success", status: :ok
    else
      render text: "Fail", status: 406
    end
  end
  def get_project_stages
    render :partial=>"sort_project_status"
  end

  # POST settings/add_user_designation
  def add_user_designation
    render(text: 'failed', status: :not_acceptable) && return if params[:name].blank?
    exist_desg = @current_organization.user_designations.where("lower(name) =?", params[:name].downcase.strip).first
    render(text: 'desg_exists', status: :not_acceptable) && return if exist_desg.present?
    user_designation = @current_organization.user_designations.new({name: params[:name]})
    if user_designation.save
      render partial: 'listing_user_designations', status: :ok
    else
      render text: 'success', status: :internal_server_error
    end
  end

  # POST settings/update_user_designation
  def update_user_designation
    render(text: 'failed', status: :not_acceptable) && return if params[:id].blank?
    exist_desg = @current_organization.user_designations.where("lower(name) =?", params[:name].downcase.strip).first
    render(text: 'desg_exists', status: :not_acceptable) && return if exist_desg.present?
    begin
      user_designation = @current_organization.user_designations.find_by_id params[:id]
      user_designation.update_attributes({name: params[:name]})
      render partial: 'listing_user_designations', status: :ok
    rescue
     render text: 'success', status: :internal_server_error
    end
  end
  # Delete user designation
  def delete_user_designation
    user_desg = @current_organization.user_designations.find_by_id(params[:id])
    if user_desg.destroy
      render text: "Success", status: :ok
    else
      render text: "Fail", status: 406
    end
  end
  # POST settings/add_user_hourly_billable
  def add_user_hrly_billable
    render(text: 'failed', status: :not_acceptable) && return if params[:amount].blank?
    exist_amount = @current_organization.user_hourly_billables.where("amount=?", params[:amount].strip).first
    render(text: 'amount_exists', status: :not_acceptable) && return if exist_amount.present?
    user_hrly_billable = @current_organization.user_hourly_billables.new({amount: params[:amount]})
    if user_hrly_billable.save
      render partial: 'listing_user_hourly_billables', status: :ok
    else
      render text: 'success', status: :internal_server_error
    end
  end

  # POST settings/update_user_hourly_billable
  def update_user_hrly_billable
    render(text: 'failed', status: :not_acceptable) && return if params[:id].blank?
    exist_amount = @current_organization.user_hourly_billables.where("amount=?", params[:amount].strip).first
    render(text: 'amount_exists', status: :not_acceptable) && return if exist_amount.present?
    begin
      user_hrly_billable = @current_organization.user_hourly_billables.find_by_id params[:id]
      user_hrly_billable.update_attributes({amount: params[:amount]})
      render partial: 'listing_user_hourly_billables', status: :ok
    rescue
     render text: 'success', status: :internal_server_error
    end
  end
  # Delete user_hourly_billable
  def delete_user_hrly_billable
    user_hrly_billable = @current_organization.user_hourly_billables.find_by_id(params[:id])
    if user_hrly_billable.destroy
      render text: "Success", status: :ok
    else
      render text: "Fail", status: 406
    end
  end
end
