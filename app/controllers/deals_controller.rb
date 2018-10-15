require 'will_paginate/array'
require 'csv'

class DealsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  include ApplicationHelper 
  include ContactsHelper
  include DealsHelper
  include HotLeadAssignment

  #caches_action :show
  #cache_sweeper :cache_sweeper
  skip_before_filter :authenticate_user!, :only => [:accept_assign_deal, :deny_assign_deal]
  before_filter :decrypt_id, :only => [:show, :edit, :update, :destroy]
  def index
    @filter_msg=nil
    associated_by=nil
    if params[:assigned_to].present?
      user = params[:assigned_to] == "me" ? @current_user : User.where(" organization_id=? AND id=?", @current_organization.id, params[:assigned_to]).first
      associated_by="assigned to"
    elsif params[:created_by].present?
      user = User.where(" organization_id=? AND id=?", @current_organization.id, params[:created_by]).first
      associated_by="created by"
    end

    if user.present?
      name = (user.id == current_user.id) ? "me" : user.full_name
      new_deal_condition = get_deal_status_count([1, 2, 3, 4, 5, 6], user, associated_by)
      new_deal_count_condition = get_deal_status_count([1])
      count_total = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(new_deal_count_condition).where("is_remote=0 and deal_statuses.original_id IN (?) and deal_statuses.is_active=? ", [1], true).count
      @new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(new_deal_condition).where("is_remote=0 and deal_statuses.original_id IN (?) ", [1]).count
      user_condition = get_deal_index_status_count([1, 2, 3, 4, 5, 6], user, associated_by)
      @total_new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(user_condition).where("is_remote=0 and deal_statuses.original_id IN (?) and deal_statuses.is_active =?", [1], true).count
      unless (params[:q].present? && params[:y].present?)
        @filter_msg=""
      end
    end
    count_condition=get_deal_status_count([1, 2, 3, 4, 5, 6])

    if request.format.csv?
      #@leads = @current_organization.deals.order("created_at desc")
      unless @current_user.is_admin?
        @leads = @current_organization.deals.joins(:deals_contacts).where("deals.is_active = true and ((deals.assigned_to = #{@current_user.id} or deals.initiated_by = #{@current_user.id} ) or (deals_contacts.contactable_type = 'IndividualContact' and deals_contacts.contactable_id in (select id from individual_contacts where owner_id = #{@current_user.id})))").order("created_at desc")
      else
        @leads = @current_organization.deals.where(:is_active=>true).order("created_at desc")
      end
    end
    datatable = DealsDatatable.new(view_context)
    if request.format.pdf?
      @deals = datatable.get_deals_pdf
    end
    #@title = "Lead Listings | Lead Management Tool | InSet CRM"
    @description = "InSet CRM lead management tool , lead listing page for user. User can check all his lead in this page."
    respond_to do |format|
      format.html
      format.json { render json: DealsDatatable.new(view_context) }
      format.csv { send_data @leads.to_csv, :filename => 'export-leads-' + Time.zone.now.strftime("%Y%m%d%I%M%S").to_s + '.csv' }
      format.pdf do
        render pdf: "Deals_#{@current_organization.name}", template: "deals/leads_pdf", encoding: "UTF-8", show_as_html: false
      end
    end
  end

  def get_inactive_deals
    render :partial => "deals/attention_deal_list"
  end

  def get_incoming_deals
    render :partial => "deals/deal_incoming"
  end

  def get_working_on_deals
    render :partial => "deals/deal_working"
  end

  def get_won_deals
    render :partial => "deals/deal_won"
  end

  def get_lost_deals
    render :partial => "deals/deal_lost"
  end

  def get_qualify_deals
    render :partial => "deals/deal_qualify"
  end

  def get_not_qualify_deals
    render :partial => "deals/deal_not_qualify"
  end

  def get_junk_deals
    render :partial => "deals/deal_junk"
  end

  def get_un_assigned_deals
    render :partial => "deals/deal_un_assigned"
  end

  def get_other_deals
    params[:dtype] = params[:dtype].present? ? params[:dtype] : "all"
    puts "---------coming to other deal-------"
    Analytics.track(

        user_id: current_user.id,
        event: 'Filter Lead',
        properties: {first_name: current_user.first_name,
                     last_name: current_user.last_name,
                     email: current_user.email,
                     filtered_by: params[:dtype]
        })
    render :partial => "deals/deal_other"
  end

  def leads_pdf
    @deals = @current_organization.deals.order("created_at desc")
    if @deals.present?
      respond_to do |format|
        format.html
        format.pdf do
          render  pdf: "Deals_#{@current_organization.name}", show_as_html: false
        end
      end
    else
      render :text => "fail"
    end
  end

  def show
    query_condition=[]
    query_condition.where("deals.id = ? and deals.organization_id=?", params[:id], @current_organization.id)
    @notes = @current_organization.notes.where(notable_type: "Deal", notable_id: params[:id]).order("created_at desc")
    @note = Note.new()
    unless @current_user.is_admin? || @current_user.is_super_admin? || @current_user.is_lead_owner?(params[:id])
      query_condition.where("(is_public=? OR (deals.assigned_to=? OR deals.initiated_by=?))", true, @current_user.id, @current_user.id)
    end

    unless (@deal=Deal.includes(:priority_type, :deal_source, :assigned_user, :deal_source, :deal_status, :initiator).where(query_condition).first).present?
      flash[:bowarning]="It seems you don't have sufficient privilege to access this item or something went wrong with your account permissions.<br/> Please contact Admin to get this fixed."
      redirect_to leads_path
    end
  end

  def deal_contacts_info
    @deal_contacts=DealsContact.where("organization_id=? AND deal_id=?", @current_user.organization_id, params[:id])
    render partial: "deal_contacts_info"
  end


  def new
    @cat = @@category
  end

  def create
    contact = nil
    
      full_name = params[:deal][:first_name] ? params[:deal][:first_name] : params[:hidden_first_name]
      split_name = full_name.strip.split(" ")
      join_name = split_name[0..-2].join(" ")
      if join_name.present?
        con_first_name = join_name
        con_last_name = split_name.last
      else
        con_first_name = full_name
        con_last_name = ""
      end
      if params[:deal][:email].present?
        ic_cont = IndividualContact.where("email = ? AND organization_id =?", params[:deal][:email], @current_organization.id).first
      else
        ic_cont = IndividualContact.where("first_name = ? AND last_name = ? AND organization_id =?", con_first_name, con_last_name, @current_organization.id).first
      end
      if !params[:deal][:contact_id].present? && !ic_cont.present?

        ic= IndividualContact.new
        ic.organization_id=current_user.organization_id        
        ic.first_name = con_first_name
        ic.last_name = con_last_name
        
        ic.email = params[:deal][:email]
        ic.country_id = params[:deal][:country_id]
        # ic.work_phone = params[:deal][:work_phone]
        #ic.extension = params[:extension_deal_popup]
        ic.created_by = current_user.id
        ic.owner_id = current_user.id
        if ic.save
          if (!params[:deal][:country].nil? && !params[:deal][:country].blank?)
            #save_contact_to_address ic,params[:deal][:country]
          end
          if (!params[:deal][:work_phone].nil? && !params[:deal][:work_phone].blank?)
            ic.update_column :work_phone, params[:deal][:work_phone]
            save_contact_to_phone ic,params[:deal][:work_phone],params[:extension_deal_popup], "work"
          end
          contact = ic
        else
          contact = nil
          alert_msg=""
          msgs=ic.errors.messages
          msgs.keys.each_with_index do |m, i|
            alert_msg=m.to_s.camelcase+" "+msgs[m].first
            alert_msg += "<br />" if i > 0
          end
        end
      elsif( (!params[:deal][:contact_id].present? && ic_cont.present?) || (params[:deal][:contact_id].present? && params[:company_type].present?) )

        if !params[:deal][:contact_id].present? && ic_cont.present?
          contact = ic_cont
        elsif params[:deal][:contact_id].present? && params[:company_type].present?
          contact = eval(params[:company_type]).find params[:deal][:contact_id]
        end

        #------------do not update the data if contact found-------
        # individual_contact={}
        # individual_contact[:work_phone] = params[:deal][:work_phone] if params[:deal][:work_phone].present?
        # individual_contact[:mobile_number] = contact.phones.by_phone_type("mobile").first.phone_no if contact.phones.present? && contact.phones.by_phone_type("mobile").present?
        # if contact.address.present?
        #   individual_contact[:street]= contact.address.address if contact.address.address.present?
        #   individual_contact[:city]= contact.address.city if contact.address.city.present?
        #   individual_contact[:state]= contact.address.state if contact.address.state.present?
        #   individual_contact[:zip_code]= contact.address.zipcode if contact.address.zipcode.present?
        # end
        # individual_contact[:email] = params[:deal][:email] if params[:deal][:email].present?
        # individual_contact[:country_id] = params[:deal][:country_id] if params[:deal][:country].present?
        # contact.update_attributes(individual_contact)
        # contact = Contact.find params[:deal][:contact_id]
      elsif( params[:deal][:contact_id].present? && params[:deal][:contact_id] != "0")
        contact = IndividualContact.find(params[:deal][:contact_id])
      end

      if !params[:company_id].present? && params[:company_value].present?
        cc=CompanyContact.new
        cc.organization = current_user.organization
        cc.name = params[:company_value]
        cc.country_id = params[:deal][:country_id]
        cc.created_by = current_user.id
        if cc.save
          contact.update_column(:company_contact_id, cc.id) if contact
          Address.create :organization => current_user.organization, :addressable => cc, :country_id=>params[:deal][:country_id]
        end
      else
        if params[:company_id].present?
          cc = @current_organization.company_contacts.where("id =?", params[:company_id]).first
          cc.country_id = params[:deal][:country_id]
          cc.save
          if cc.address.present?  
            cc.address.update_attributes({:country_id=>params[:deal][:country_id]})
          else
            Address.create :organization => current_user.organization, :addressable => cc, :country_id=>params[:deal][:country_id]
          end
          contact.update_column(:company_contact_id, cc.id)
        end
      end
      if contact.present?
        deal = Deal.new
        deal.organization = current_user.organization
        deal.title=params[:deal][:title]
        #deal.amount=params[:deal][:amount]
        deal.initiated_by = current_user.id
        deal.assigned_to = params[:deal][:assigned_to]
        deal.country_id = params[:deal][:country_id]
        deal.priority_type = current_user.organization.hot_priority()
        deal.deal_status = @current_organization.deal_statuses.where("id=?", params[:deal][:deal_status_id]).first
        #@current_organization.deal_statuses.where("name NOT IN (?)", ['won', 'lost']).order("original_id").first
        deal.is_active=true
        deal.is_current=false
        deal.is_public = params[:deal][:is_public]
        # deal.is_public= contact.is_public
        deal.expected_close_date = Date.strptime(params[:deal][:expected_close_date], "%m/%d/%Y") if params[:deal][:expected_close_date].present?
        deal.currency_type= params[:deal][:currency_type]
        deal.deals_contacts.build(organization_id: deal.organization_id, contactable_id: contact.id, contactable_type: contact.class.name)
        deal.billing_type=params[:deal][:billing_type]
        deal.duration=params[:deal][:duration]
        deal.comments=params[:deal][:comments]
        deal.user_label_id = params[:deal][:user_label_id].present? ? params[:deal][:user_label_id] : @current_organization.user_labels.where("name = ?", "Inbound").first.id
        
        if params[:deal][:billing_type] == "Custom"
          deal.custom_value=params[:deal][:custom_value]
        else
          unless params[:deal][:billing_type] == "Fixed bid"
            if deal.duration.to_i > 0
              deal.amount=params[:deal][:amount].to_f*deal.duration.to_i
              deal.ref_billing_amount=params[:deal][:amount]
            else
              deal.amount=params[:deal][:amount]
              deal.ref_billing_amount=params[:deal][:amount]
            end
          else
            deal.duration= nil
            deal.amount=params[:deal][:amount]
            deal.ref_billing_amount= deal.amount
          end
        end
        deal.save
        
        if params[:deal][:source_id].present?
          DealSource.create(:organization => @current_organization, :deal_id => deal.id, :source_id => params[:deal][:source_id])
        end
        if @current_organization.deals.count == 1
          deal_statuses = @current_organization.deal_statuses
          deal_statuses.update_all :is_kanban => true
        end
        insert_deal_activity(deal,ic.present? ? ic : nil)
        Analytics.track(
            user_id: current_user.id,
            event: 'Add Lead',
            properties: {first_name: current_user.first_name,
                         last_name: current_user.last_name,
                         email: current_user.email,
                         lead_title: deal.title
            })

        flash[:bosuccess] = "A new Opportunity has been added. Let's keep going!"
        # if params[:opportunity_popup].present?
        #   flash[:bosuccess] = "A new Opportunity has been added. Let's keep going!"
        # end
        unless params[:allnew].nil? && params[:allnew].blank?
          update_deal_data(deal)
        end
        if !params[:allnew].nil? && !params[:allnew].blank?

          redirect_to leads_path
        elsif params[:is_edit_deal] == 'true'
          #redirect_to edit_lead_path(deal)
          render :text => "#{deal.to_param}" + '-success'
        else
          render :text => 'success'
        end
      else
        render text: alert_msg.to_s
      end
     
  end

  def insert_opportunities deal
    puts "==============       insert_opportunities   ========================"
    assigned_user = deal.assigned_user

    unless deal.assigned_user.nil? || deal.assigned_user != 0
      org_id = assigned_user.organization.id
      #org_id = current_user.organization
      current_quarter = get_current_quarter Date.today
      current_year = Time.zone.now.year
      case current_quarter
        when 1
          start_date = DateTime.new(Time.zone.now.year, 1, 1)
          end_date = DateTime.new(Time.zone.now.year, 3, 31)
        when 2
          start_date = DateTime.new(Time.zone.now.year, 4, 1)
          end_date = DateTime.new(Time.zone.now.year, 6, 30)
        when 3
          start_date = DateTime.new(Time.zone.now.year, 7, 1)
          end_date = DateTime.new(Time.zone.now.year, 9, 30)
        when 4
          start_date = DateTime.new(Time.zone.now.year, 10, 1)
          end_date = DateTime.new(Time.zone.now.year, 12, 31)
      end

      assigned_deals = assigned_user.all_assigned_deal.by_is_active.by_range(start_date, end_date).count
      won_deals = get_deal_status_won_count(assigned_user, [4], start_date, end_date).count

      win_percentage = calculate_win_percentage(assigned_deals, won_deals)
      insert_or_update_opportunity(assigned_user.id, org_id, current_year, current_quarter, assigned_deals, won_deals, win_percentage)
    end
    puts "==============       insert_opportunities ends here  ========================"
  end

  def insert_opportunities_for_user user_id
    begin
      puts "==============       insert_opportunities for user #{user_id}  ========================"
      assigned_user = User.find user_id.to_i

      if assigned_user.present?
        p assigned_user.id
        puts "=========> statrted processsing for user"
        org_id = assigned_user.organization.id
        #org_id = current_user.organization
        current_quarter = get_current_quarter Date.today
        current_year = Time.zone.now.year
        case current_quarter
          when 1
            start_date = DateTime.new(Time.zone.now.year, 1, 1)
            end_date = DateTime.new(Time.zone.now.year, 3, 31)
          when 2
            start_date = DateTime.new(Time.zone.now.year, 4, 1)
            end_date = DateTime.new(Time.zone.now.year, 6, 30)
          when 3
            start_date = DateTime.new(Time.zone.now.year, 7, 1)
            end_date = DateTime.new(Time.zone.now.year, 9, 30)
          when 4
            start_date = DateTime.new(Time.zone.now.year, 10, 1)
            end_date = DateTime.new(Time.zone.now.year, 12, 31)
        end

        assigned_deals = assigned_user.all_assigned_deal.by_is_active.by_range(start_date, end_date).count
        won_deals = get_deal_status_won_count(assigned_user, [4], start_date, end_date).count

        win_percentage = calculate_win_percentage(assigned_deals, won_deals)
        insert_or_update_opportunity(assigned_user.id, org_id, current_year, current_quarter, assigned_deals, won_deals, win_percentage)
      end
      puts "==============       insert_opportunities for user ends here  ========================"
    rescue Exception => e
      puts "==========> Heyy !! we got an error"
      puts e.message
      puts e.backtrace.inspect
    end
  end


  def insert_salescycle deal
    puts "==============        insert_salescycle deal         ========================"
    assigned_user = deal.assigned_user
    org_id = assigned_user.organization.id
    current_quarter = get_current_quarter Date.today
    current_year = Time.zone.now.year
    case current_quarter
      when 1
        start_date = DateTime.new(Time.zone.now.year, 1, 1)
        end_date = DateTime.new(Time.zone.now.year, 3, 31)
      when 2
        start_date = DateTime.new(Time.zone.now.year, 4, 1)
        end_date = DateTime.new(Time.zone.now.year, 6, 30)
      when 3
        start_date = DateTime.new(Time.zone.now.year, 7, 1)
        end_date = DateTime.new(Time.zone.now.year, 9, 30)
      when 4
        start_date = DateTime.new(Time.zone.now.year, 10, 1)
        end_date = DateTime.new(Time.zone.now.year, 12, 31)
    end


    average_time = Deal.find_avg_deal_ratio_status_won assigned_user.id, org_id, start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")

    puts "===== average_time==========="


    insert_or_update_salescycle(assigned_user.id, org_id, current_year, current_quarter, average_time[0], average_time[1], average_time[2])

  end

  def insert_deal_activity deal, individual_contact
    if deal
      org_id = deal.organization_id if deal.organization_id
      activity_type = deal.class.name
      activity_id = deal.id
      activity_user_id = deal.initiated_by ? deal.initiated_by : ""
      activity_date = deal.created_at
      activity_desc = deal.title
      activity_status = "Create"
      public_status = (deal.is_public.nil? || deal.is_public.blank?) ? false : deal.is_public
      ic_a1 = Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id, :activity_type => "IndividualContact", :activity_id => individual_contact.id, :activity_status => "Create", :activity_desc => individual_contact.full_name.present? ? individual_contact.full_name : individual_contact.email, :activity_date => individual_contact.created_at, :is_public => true, :source_id => individual_contact.id, :source_type => individual_contact.class.name) if individual_contact.present?

      ad1 = Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id, :activity_type => activity_type, :activity_id => activity_id, :activity_status => activity_status, :activity_desc => activity_desc, :activity_date => activity_date, :is_public => true, :source_id => activity_id, :source_type => deal.class.name)

      ActivitiesContact.create({:organization_id => org_id, activity_id: ad1.id, contactable_type: "IndividualContact", contactable_id: individual_contact.id}) if individual_contact.present?
      ActivitiesContact.create({:organization_id => org_id, activity_id: ic_a1.id, contactable_type: "IndividualContact", contactable_id: individual_contact.id}) if individual_contact.present?

      a1 = Activity.create(:organization_id => org_id, :activity_user_id => deal.assigned_to.present? ? deal.assigned_user.id : "", :activity_type => activity_type, :activity_id => activity_id, :activity_status => "Assign", :activity_desc => activity_desc, :activity_date => activity_date, :is_public => true, :source_id => activity_id, :activity_by => @current_user.id,source_type: deal.class.name)
      if a1.id.present? && !deal.is_csv?
        deal.update_column :last_activity_date, a1.activity_date
      end
      # if deal.attachments
      # deal.attachments.each do |note|
      # if note.present?
      # a2 = Activity.create(:organization_id => note.organization_id,  :activity_user_id => note.created_by ? note.created_by : "",:activity_type=> note.class.name, :activity_id => note.id, :activity_status => "Create",:activity_desc=>note.notes,:activity_date => note.created_at, :is_public => true, :source_id => activity_id)
      # if a2.id.present?
      # deal.update_column :last_activity_date,  a2.activity_date
      # end
      # end
      # end
      # end
      #comment for initial note
      # if deal.comments
      # #a2 = Activity.create(:organization_id => org_id,  :activity_user_id => note.created_by ? note.created_by : "",:activity_type=> note.class.name, :activity_id => note.id, :activity_status => "Create",:activity_desc=>note.notes,:activity_date => note.created_at, :is_public => true, :source_id => activity_id)
      # a2 =Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id,:activity_type=> "Note", :activity_id => activity_id, :activity_status =>"Create",:activity_desc=>deal.comments ,:activity_date => activity_date, :is_public => true, :source_id => activity_id)
      # if a2.id.present?
      # deal.update_column :last_activity_date,  a2.activity_date
      # end
      # end

      if deal.deals_contacts
        deal.deals_contacts.each do |contact|
          if contact.contactable
            record = contact.contactable
            org_id = record.organization_id if record.organization_id
            activity_type = contact.contactable.class.name
            activity_id = record.id
            activity_user_id = record.created_by ? record.created_by : ""
            activity_date = record.created_at
            activity_desc = record.full_name
            activity_status = "Create"
            public_status = (record.is_public.nil? || record.is_public.blank?) ? false : record.is_public

            a3 = Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id, :activity_type => activity_type, :activity_id => activity_id, :activity_status => activity_status, :activity_desc => activity_desc, :activity_date => activity_date, :is_public => true, :source_id => deal.id,:source_type=> deal.class.name)
            if a3.id.present? && !deal.is_csv?
              deal.update_column :last_activity_date, a3.created_at
            end
          end
        end
      end
    end
  end

  def edit
    session[:prev_page] = nil
    session[:prev_page] = request.referer
    @deal = Deal.includes(:deals_contacts, :deal_source, :deal_industry).find(params[:id])
    unless (@deal.associated_users.include? @current_user.id) || (@current_user.is_admin? || @current_user.is_super_admin?)
      flash[:alert]="It seems you don't have sufficient privilege to access this item or something went wrong with your account permissions.<br/> Please contact Admin to get this fixed."
      redirect_to "/leads"
    end
    @cat = @@category
    #@contact=@deal.deals_contacts.first.contactable
    #@work_phone = @contact.phones.by_phone_type "work"
    #@mobile_phone = @contact.phones.by_phone_type "mobile" 
  end

  def edit_deal
    session[:prev_page] = nil
    session[:prev_page] = request.referer
    @deal = Deal.includes(:deals_contacts, :deal_source, :deal_industry).find(params[:id])
    @cat = @@category
    render partial: "deal_edit", :content_type => 'text/html'
  end

  def update
    deal = @current_organization.deals.find_by_id(params[:id])
    update_deal_data(deal)
    if session[:prev_page].nil? || session[:prev_page].include?("/dashboard")
      session[:prev_page] = leads_path
    end

    begin
      Analytics.track(
          user_id: current_user.id,
          event: 'Update Lead',
          properties: {first_name: current_user.first_name,
                       last_name: current_user.last_name,
                       email: current_user.email,
                       lead_title: deal.title
          })
    rescue
    end


    flash[:bosuccess] = "Your lead info has been updated. It's a good habit to be up-to-date. Yeah!"
    if !request.xhr?
      if params[:quick_edit].present?
        redirect_to request.referrer
      else
        redirect_to (session[:prev_page].nil? || session[:prev_page].include?('edit_individual_contact') || session[:prev_page].include?('edit_company_contact')) ? leads_path : session[:prev_page]
        session[:prev_page] = nil
      end
    else
      flash[:bosuccess] = "Wow! That was quick. But I noticed... Lead info updated!"
      render :text => "success"
    end
  end

  def deals_woking_on
    deal = Deal.find params[:id]
    deal.update_attribute(:is_current, true)
    redirect_to request.referer
  end

  def update_deal_data(deal)
    begin
      full_name = params[:deal][:first_name] ? params[:deal][:first_name] : params[:hidden_first_name]
      split_name = full_name.strip.split(" ")
      join_name = split_name[0..-2].join(" ")
      if join_name.present?
        con_first_name = join_name
        con_last_name = split_name.last
      else
        con_first_name = full_name
        con_last_name = ""
      end
      if params[:deal][:email].present?
        ic_cont = IndividualContact.where("email = ? AND organization_id =?", params[:deal][:email], @current_organization.id).first
      else
        ic_cont = IndividualContact.where("first_name = ? AND last_name = ? AND organization_id =?", con_first_name, con_last_name, @current_organization.id).first
      end
        
      # ic_cont = IndividualContact.where("email = ? AND organization_id =?", params[:deal][:email], @current_organization.id).first
        
      if !params[:deal][:contact_id].present? && !ic_cont.present?
        ic= IndividualContact.new
        ic.organization_id=current_user.organization_id
        full_name = params[:deal][:first_name] ? params[:deal][:first_name] : params[:hidden_first_name]
        split_name = full_name.split(" ")
        join_name = split_name[0..-2].join(" ")
        if join_name.present?
          ic.first_name = join_name
          ic.last_name = split_name.last
        else
          ic.first_name = full_name
        end
        ic.email = params[:deal][:email]
        ic.country_id = params[:deal][:country_id]
        ic.created_by = current_user.id
        ic.owner_id = current_user.id
        if ic.save
          if (!params[:deal][:country].nil? && !params[:deal][:country].blank?)
            #save_contact_to_address ic,params[:deal][:country]
          end
          if (!params[:deal][:work_phone].nil? && !params[:deal][:work_phone].blank?)
            ic.update_column :work_phone, params[:deal][:work_phone]
            save_contact_to_phone ic,params[:deal][:work_phone],params[:extension_deal_popup], "work"
          end
          contact = ic
        else
          contact = nil
          alert_msg=""
          msgs=ic.errors.messages
          msgs.keys.each_with_index do |m, i|
            alert_msg=m.to_s.camelcase+" "+msgs[m].first
            alert_msg += "<br />" if i > 0
          end
        end
      elsif( (!params[:deal][:contact_id].present? && ic_cont.present?) || (params[:deal][:contact_id].present? && params[:company_type].present?) )

        if !params[:deal][:contact_id].present? && ic_cont.present?
          contact = ic_cont
        elsif params[:deal][:contact_id].present? && params[:company_type].present?
          contact = eval(params[:company_type]).find params[:deal][:contact_id]
        end
      end

      #deal.title=params[:deal][:title]
      deal.title=params[:deal][:title] if params[:deal][:title]
      #deal.amount=params[:deal][:amount]
      deal.assigned_to = params[:deal][:assigned_to]
      #deal.tags = params[:deal][:tags]
      deal.tag_list = params[:deal][:tag_list]
      deal.comments = params[:deal][:comments]
      deal.probability = params[:deal][:probability]
      deal.attempts = params[:deal][:attempts]
      deal.billing_type = params[:deal][:billing_type] if params[:deal][:billing_type]
      deal.payment_status = params[:deal][:payment_status] if params[:deal][:payment_status]
      deal.priority_type = PriorityType.find(params[:deal][:priority_type]) if params[:deal][:priority_type]
      deal.is_public = params[:deal][:is_public]
      deal.currency_type = params[:deal][:currency_type]
      deal.user_label_id = @current_organization.user_labels.where("name=?","Inbound").first.id
      deal.expected_close_date = Date.strptime(params[:deal][:expected_close_date], "%m/%d/%Y") if params[:deal][:expected_close_date].present?
      deal.duration=params[:deal][:duration]
      deal.deal_status = @current_organization.deal_statuses.where("id=?", params[:deal][:deal_status_id]).first

      
      if params[:deal][:billing_type] == "Custom"
        deal.custom_value = params[:deal][:custom_value]
      else
        deal.custom_value = nil
        unless params[:deal][:billing_type] == "Fixed bid"
          if deal.duration.to_i > 0
            deal.amount=params[:deal][:amount].to_f*deal.duration.to_i
            deal.ref_billing_amount=params[:deal][:amount]
          else
            deal.amount=params[:deal][:amount]
            deal.ref_billing_amount=params[:deal][:amount]
          end
        else
          deal.duration= nil
          deal.amount=params[:deal][:amount]
          deal.ref_billing_amount= deal.amount
        end
      end

      if contact.present?
        deals_contact = deal.deals_contacts.first
        deals_contact.update_attributes(organization_id: deal.organization_id, contactable_id: contact.id, contactable_type: contact.class.name)
        puts deals_contact.inspect
      end

      if params[:deal][:source_id].present?
        deal_source = @current_organization.deal_sources.where(:deal_id => deal.id).first
        if deal_source.present?
          deal_source.update_column(:source_id, params[:deal][:source_id])
        else
          DealSource.create(:organization => @current_organization, :deal_id => deal.id, :source_id => params[:deal][:source_id])
        end
      end

      if params[:deal][:industry_id].present?
        deal_industry = @current_organization.deal_industries.where(:deal_id => deal.id).first
        if deal_industry.present?
          deal_industry.update_column(:industry_id, params[:deal][:industry_id])
        else
          DealIndustry.create(:organization => @current_organization, :deal_id => deal.id, :industry_id => params[:deal][:industry_id])
        end
      end

      # if params[:duration_type].present? && params[:deal][:duration].present?
      #   deal.duration = params[:deal][:duration] + "," + params[:duration_type]
      # else
      #   deal.duration = nil
      # end
      deal.save

      if (deal.deal_source.nil? && !params[:deal][:deal_source].nil? && !params[:deal][:deal_source].blank?)
        dls = DealSource.create(:organization => @current_organization, :deal => deal, :source_id => params[:deal][:deal_source])
      elsif (!deal.deal_source.nil? && !params[:deal][:deal_source].nil? && !params[:deal][:deal_source].blank?)
        deal.deal_source.update_attribute :source_id, params[:deal][:deal_source]
      end
      #save deal industry

      if (deal.deal_industry.nil? && !params[:deal][:deal_industry].nil? && !params[:deal][:deal_industry].blank?)
        dls = DealIndustry.create(:organization => @current_organization, :deal => deal, :industry_id => params[:deal][:deal_industry])
      elsif (!deal.deal_industry.nil? && !params[:deal][:deal_industry].nil? && !params[:deal][:deal_industry].blank?)
        deal.deal_industry.update_attribute :industry_id, params[:deal][:deal_industry]
      end
    rescue
    end
  end

  def apply_label_to_deal
    deals = params[:deals].split(",")
    labels = params[:labels].split(",")
    deals.each do |dl|
      labels.each do |lbl|
        userdeal_label = DealLabel.find(:first, :conditions => ["user_label_id= ? and deal_id = ?", lbl, dl])
        p userdeal_label.nil?
        if (userdeal_label.nil?)
          DealLabel.create(:organization => current_user.organization, :deal_id => dl, :user_label_id => lbl)
        end
      end

    end
    render :text => "success"
  end

  def apply_label_to_single_deal
    labels = params[:labels].split(",")
    labels.each do |lbl|
      userdeal_label = DealLabel.find(:first, :conditions => ["user_label_id= ? and deal_id = ?", lbl, params[:deal]])
      if (userdeal_label.nil?)
        DealLabel.create(:organization => current_user.organization, :deal_id => params[:deal], :user_label_id => lbl)
      end
    end
    render :text => "success"
  end

  def move_lead
    if params[:mass_deal_ids].present?
      response_msg = ""
      deal_ids = params[:mass_deal_ids].split(',')
      dealscount = deal_ids.length.to_i;
      deal_ids.each do |d|
        deal = @current_organization.deals.find d
        # dm = DealMove.create(:organization => current_user.organization, :deal_id => d, :deal_status_id => params[:deal_move][:deal_status], :user => current_user)
        # if !params[:deal_move][:note].nil? && !params[:deal_move][:note].blank?
        #   Note.create(:organization => current_user.organization, :notes => params[:deal_move][:note], :created_by => current_user.id, :notable => dm)
        # end
        deal.deal_status_id = params[:deal_move][:deal_status]
        deal.assigned_to = params[:assigned_to_user]
        if (!params[:deal_move][:is_current].nil? && !params[:deal_move][:is_current].blank?)
          deal.is_current= 0 if params[:deal_move][:is_current] == "1"
        end
        # if (dm.deal_status.original_id == 4 || dm.deal_status.original_id == 5)
        #   deal.is_current=false
        # end
        deal.move_deal = true
        deal.save
        if d == deal_ids.last
          response_msg = {status: true, msg: "Lead has been moved successfully.", deal_org_id: deal.deal_status.original_id, total_deal: dealscount}
        end
        # if (dm.deal_status.original_id == 4)
        #   deal.update_column :closed_by, current_user.id
        #   c_name = current_user.full_name
        #   # NotifyMoveWonDeal.perform_async("#{current_user.organization_id}", "#{deal.id}", c_name)
        #   # InsertOpportunity.perform_async("#{deal.id}")
        #   # InsertSalescycle.perform_async("#{deal.id}")
        # else
        #   # InsertOpportunity.perform_async("#{deal.id}")
        # end

      end

    else ## else of params[:mass_deal_ids].present?
      deal = Deal.find params[:deal_id]
      dealscount = 1;
      # dm = DealMove.create(:organization => current_user.organization, :deal_id => params[:deal_id], :deal_status_id => params[:deal_move][:deal_status], :user => current_user)
      # if !params[:deal_move][:note].nil? && !params[:deal_move][:note].blank?
      #   Note.create(:organization => current_user.organization, :notes => params[:deal_move][:note], :created_by => current_user.id, :notable => dm)
      # end
      deal.deal_status_id = params[:deal_move][:deal_status]
      deal.assigned_to = params[:assigned_to_user]
      if (!params[:deal_move][:is_current].nil? && !params[:deal_move][:is_current].blank?)
        deal.is_current= 0 if params[:deal_move][:is_current] == "1"
      end
      # if (dm.deal_status.original_id == 4 || dm.deal_status.original_id == 5)
      #   deal.is_current=false
      # end
      deal.move_deal = true
      deal.save
      # if (dm.deal_status.original_id == 4)
      #   deal.update_column :closed_by, current_user.id
      #   c_name = current_user.full_name
      #   #NotifyMoveWonDeal.perform_async("#{current_user.organization_id}","#{deal.id}",c_name)
      #   #InsertOpportunity.perform_async("#{deal.id}")
      #   #InsertSalescycle.perform_async("#{deal.id}")
      # else ## else of dm.deal_status.original_id == 4
      #   #InsertOpportunity.perform_async("#{deal.id}")
      # end

    end
    # if !request.xhr?
    if params[:mass_deal_ids].present?
      #redirect_to leads_path
      # flash[:notice]="Deal has been moved successfully."
      # redirect_to request.referrer
      #  stage_info={status: true, msg: "Lead has been moved successfully.", stag_name: deal.deal_status_name, assigned_user: deal.assigned_user == @current_user ? "Me" : deal.assigned_user.full_name,assigned_user_id: deal.assigned_user.id,deal_org_id: deal.deal_status.original_id, total_deal: dealscount}
      stage_info= response_msg
    else
      stage_info={status: true, msg: "Lead has been moved successfully.", stag_name: deal.deal_status_name, assigned_user: deal.assigned_user.present? && deal.assigned_user == @current_user ? "Me" : (deal.assigned_user.present? && deal.assigned_user.full_name.present? ? deal.assigned_user.full_name : "Me"), assigned_user_id: deal.assigned_user.present? ? deal.assigned_user.id : @current_user.id, deal_org_id: deal.deal_status.original_id, total_deal: dealscount}
    end
    render :json => stage_info.to_json
  end

  def deal_setting
    if !current_user.deal_setting.nil?
      current_user.deal_setting.update_attributes :tabs => params['tabs'].flatten.join(',')
    else
      DealSetting.create(:organization => current_user.organization, :user => current_user, :tabs => params[:tabs].flatten.join(','))
    end
    redirect_to leads_path
  end


  def delete_selected_deals
    if params[:deal_ids_to_delete].include?(',')
      deal_ids=params[:deal_ids_to_delete].chop
    else
      deal_ids=params[:deal_ids_to_delete]
    end
    deal_ids=deal_ids.split(",")
    deal_ids.each do |id|
      deal=Deal.where(id: id).first
      if deal
        # unless deal.assigned_to.present?
          deal_contact = deal.deals_contacts.first.contactable if deal.deals_contacts.present?
          if deal_contact.present? && deal_contact.deals_contacts.present? && deal_contact.deals_contacts.count == 1
            if deal_contact.class.name == "IndividualContact"
              con = IndividualContact.find deal_contact.id
            elsif deal_contact.class.name == "CompanyContact"
              con = CompanyContact.find deal_contact.id
            end
            con.destroy
            deal.destroy
          else
            deal.destroy
          end
        # else
          # deal.update_attributes :is_active=> false, :deactivated_by => @current_user.id
          # deal.tasks.each do |task|
          #   task.update_attributes :is_archive => true, :archive_by => @current_user.id
          # end
        # end
      end
      flash[:bosuccess] = "Lead(s) has been deleted successfully!"
    end
    respond_to do |format|
      format.js { render text: "success" }
    end
  end

  def delete_opportunity_confirm
    @deal = @current_organization.deals.find_by_id(params[:deal_id])
    render :partial => "deals/delete_opportunity_confirm"
  end

  def destroy
    @deal = Deal.find(params[:id])
    # return_url = @deal.is_remote? ? leads_path(:type => "un_assigned") : leads_path
    # if params[:type].present? && params[:type] == "unassigned"
    if @deal.present?
      deal_contact = @deal.deals_contacts.first.contactable if @deal.deals_contacts.present?
      if deal_contact.present? && deal_contact.deals_contacts.present? && deal_contact.deals_contacts.count == 1
        if deal_contact.class.name == "IndividualContact"
          con = IndividualContact.find deal_contact.id
        elsif deal_contact.class.name == "CompanyContact"
          con = CompanyContact.find deal_contact.id
        end
        if params[:delete_type].present? && params[:delete_type] == "remove_permanently"
          con.destroy
        end
        @deal.destroy
      else
        @deal.destroy
      end
    end
    # else
    #   if @deal
    #     @deal.update_attributes :is_active=> false, :deactivated_by => @current_user.id
    #     @deal.tasks.each do |task|
    #       task.update_attributes :is_archive => true, :archive_by => @current_user.id
    #     end
    #   end
    # end
    flash[:bosuccess] = "Awwww! opportunity have been deleted. Don't you worry, let's focus on the better ones!"
    respond_to do |format|
      format.html { redirect_to leads_path }
      format.js { render text: "success" }
    end
  end

  def deal_task_widget
    @deal=Deal.find params[:deal_id]
    @tasks=[]
    @task_type = params[:task_type] if params[:task_type].present?
    @tasks=Task.task_list(current_user, params[:task_type], @deal) if current_user.present? && @deal.present?
    p @tasks
    render partial: "deals/widget_task_list" #, :content_type => 'text/html'
  end

  def task_widget_reload
    @deal=Deal.find params[:deal_id]
    render partial: "deals/widget_task_header" #, :content_type => 'text/html'
  end

  def bulk_lead_upload
    is_valid = false
    if params[:attachment_lead].present?
      CSV.foreach(params[:attachment_lead].path, headers: true, encoding: 'ISO-8859-1') do |row|
        #row['created_dt'] = Date.strptime row['created_dt'], '%Y-%m-%d'
        #row['created_dt']=DateTime.strptime(row['created_dt'], "%m/%d/%Y").strftime("%Y/%m/%d")

        fields_to_insert = %w{ user_id title priority company_name company_size website contact_name designation phone extension mobile email technology source location country industry comments created_dt description assigned_to facebook_url linkedin_url twitter_url skype_id task_type}
        rows_to_insert = []
        row['user_id'] = current_user.id
        if row.headers.include?("company_size") && row.headers.include?("assigned_to") && row.headers.include?("created_dt") && row.headers.include?("title")
          if row['company_size']
            row['company_size'] = row['company_size'].gsub(/[()]/, "")
          end

          if row['assigned_to']
            unless assigned_to_users.include?(row['assigned_to'].to_s)
              row['assigned_to'] = nil
            end
          end

          alltask_types = current_user.organization.task_types.map { |c| c.name.downcase.strip }
          if (!row['task_type'].present?) || !(alltask_types.include?(row['task_type'].downcase))
            row['task_type'] = "call"
          end

          if row['created_dt']
            row['created_dt'] = Date.parse(row['created_dt'].to_s)

            time_to_merge = Time.zone.now
            date_to_merge = row['created_dt'].to_date
            merged_datetime = DateTime.new(date_to_merge.year, date_to_merge.month, date_to_merge.day, time_to_merge.hour, time_to_merge.min, time_to_merge.sec)

            creadat = row['created_dt'].to_date
            if creadat >= Date.today
              row['created_dt'] = Time.zone.now
            else
              row['created_dt'] = merged_datetime
            end
          end
          
          row_to_insert = row.to_hash.select { |k, v| fields_to_insert.include?(k) }
          rows_to_insert << row_to_insert
          unless row['title'].nil? || row['title'].blank?
            TempLead.create! rows_to_insert
          end
          is_valid = true
        end
      end      
    end
    respond_to do |format|
      format.text { render text: is_valid ? "success" : "error" }
    end
  end

  def lead_preview
    @c = []
    @leads = TempLead.by_user current_user.id
    @country = Country.all
    @country.each do |a|
      @c << a.name
    end

  end

  def destroy_all_lead
    @leads = TempLead.by_user current_user.id
    @leads.destroy_all
    redirect_to leads_path
  end

  def save_lead
    ActiveRecord::Base.connection.execute("CALL import_leads_to_deals(#{current_user.id})")
    flash[:bosuccess] = "Leads have been uploaded successfully."

    # OpportunityAfterLead.perform_async
    # LeadNotification.perform_async
    redirect_to leads_path
  end

  def save_lead_phone
    lead = TempLead.find params[:name]
    if params[:pk] == "1"
      lead.update_column :phone, params[:value]
    elsif params[:pk] == "2"
      lead.update_column :mobile, params[:value]
    end
    #respond_to do |format|
    format.text { render text: "success" }
    #end
  end


  def save_lead_email
    lead = TempLead.find params[:name]
    lead.update_column :email, params[:value]
    respond_to do |format|
      format.text { render text: "success" }
    end
  end

  def save_lead_data
    @c = []

    lead = TempLead.find params[:name]
    if params[:pk] == "1"
      lead.update_column :title, params[:value]
      msg = "success"
    elsif params[:pk] == "2"
      lead.update_column :company_name, params[:value]
      msg = "success"
    elsif params[:pk] == "3"
      lead.update_column :company_size, params[:value]
    elsif params[:pk] == "4"
      lead.update_column :source, params[:value]
    elsif params[:pk] == "5"
      lead.update_column :website, params[:value]
    elsif params[:pk] == "6"
      lead.update_column :contact_name, params[:value]
    elsif params[:pk] == "7"
      lead.update_column :designation, params[:value]
    elsif params[:pk] == "8"
      lead.update_column :phone, params[:value]
    elsif params[:pk] == "9"
      lead.update_column :mobile, params[:value]
    elsif params[:pk] == "10"
      lead.update_column :email, params[:value]
    elsif params[:pk] == "11"
      lead.update_column :technology, params[:value]
    elsif params[:pk] == "12"
      lead.update_column :location, params[:value]
    elsif params[:pk] == "13"
      lead.update_column :country, params[:value]
      @country = Country.all
      @country.each do |a|
        @c << a.name
      end
    elsif params[:pk] == "14"
      lead.update_column :industry, params[:value]
    elsif params[:pk] == "15"
      lead.update_column :comments, params[:value]
    elsif params[:pk] == "16"
      lead.update_column :description, params[:value]
    elsif params[:pk] == "17"
      lead.update_column :assigned_to, params[:value]
    elsif params[:pk] == "18"
      lead.update_column :facebook_url, params[:value]
    elsif params[:pk] == "19"
      lead.update_column :twitter_url, params[:value]
    elsif params[:pk] == "20"
      lead.update_column :linkedin_url, params[:value]
    elsif params[:pk] == "21"
      lead.update_column :skype_id, params[:value]
    end
    if (params[:pk].present? && !@c.include?(params[:value]))
      msg = "error_#{lead.id}"
    else
      msg = "success_#{lead.id}"
    end
    respond_to do |format|
      #if (!@c.include?(l.country))
      #format.text {render text: "error"}
      #else
      format.text { render text: msg }
      #end
    end
  end

  def learnmore
    render :layout => false
  end

  def add_contact

    if !params[:contactable_id].present?
      ic= IndividualContact.new
      ic.organization_id=current_user.organization_id
      ic.first_name = params[:first_name]
      ic.email = params[:email]
      ic.country = params[:country]
      ic.work_phone = params[:work_phone]
      ic.extension = params[:extension_contact_popup]
      ic.created_by = current_user.id
      ic.company_contact_id=params[:comp_id] if params[:comp_id].present?
      ic.save
      DealsContact.create(:organization_id => current_user.organization_id, :deal_id => params[:deal_id], :contactable_type => "IndividualContact", :contactable_id => ic.id)
      if !params[:comp_id].present? && params[:company_value].present?
        cc=CompanyContact.new
        cc.organization = current_user.organization
        cc.name = params[:company_value]
        cc.country = params[:country]
        cc.work_phone = params[:work_phone]
        cc.time_zone = params[:time_zone][:contact]
        cc.created_by = current_user.id
        if cc.save(validate: false)
          ic.update_column(:company_contact_id, cc.id)
        end
      end
    else
      DealsContact.create(:organization_id => current_user.organization_id, :deal_id => params[:deal_id], :contactable_type => params[:contactable_type], :contactable_id => params[:contactable_id])
    end

    if !request.xhr?
      flash[:bosuccess] = "Contact has been added successfully."
      redirect_to request.referrer
    else
      render :text => "Contact has been added successfully."
    end
  end

  def delete_deal_con
    @deal_con = DealsContact.find(params[:id])
    deal= @deal_con.deal
    @deal_con.destroy
    deal.update_country_id
    flash[:bosuccess] = "Contact has been deleted successfully."
    redirect_to request.referrer
  end

  def update_deal_ttl
    deal = Deal.find params[:name]
    deal.update_column :title, params[:value]
    respond_to do |format|
      format.text { render text: "success" }
    end
  end

  def update_note_ttl
    activity = Activity.find params[:name]
    note = Note.find activity.activity_id
    activity.update_column :activity_desc, params[:value].gsub(/\n/, "<br>")
    activity.update_column :updated_at, Time.now
    note.update_column :notes, params[:value].gsub(/\n/, "<br>")
    respond_to do |format|
      format.text { render text: activity.updated_at.strftime("%I:%M %p").to_s+"~"+activity.id.to_s }
    end
  end

  def hide_note
    activity = Activity.find params[:id]
    activity.update_column :is_available, true
    respond_to do |format|
      format.text { render text: activity.id }
    end
  end

  def fetch_activity
    if (@deal = Deal.where(:id => params[:id].to_i).first).present?
      respond_to do |format|
        format.text { render partial: "time_line_stream" }
      end
    end
  end

  def fetch_user_deals
    @user = User.find params[:id]
    @deals = @user.all_assigned_or_created_deals.where("is_won IS NULL AND is_active=?",true).order("id desc").limit(2)
    respond_to do |format|
      format.text { render partial: "users/deal_list" }
    end

  end


  def get_industry_list
    if params[:type] == "industry"
      data = @current_organization.industries.select("id value, name text").where("name IS not NULL")
    elsif params[:type] == "source"
      data = @current_organization.sources.select("id value, name text").where("name IS not NULL")
    end

    respond_to do |format|
      #format.html 
      format.json { render json: data.to_json }
    end
  end

  def get_country_list
    data = Country.select("id value, name text")
    respond_to do |format|
      #format.html 
      format.json { render json: data.to_json }
    end
  end

  def save_country_lead
    #{"name"=>"34", "value"=>"7", "pk"=>"1"}
    cname = Country.where(:id => params[:value]).first.name
    if cname.present?
      TempLead.find(params[:name]).update_attribute(:country, cname)
    end
    render text: 'success'
  end

  def get_user_list_lead
    if params[:from].present?
      # data = @current_organization.users.where("invitation_token IS ? and is_active = ?", nil,true).select("id value, (case when id = " + @current_user.id.to_s + " then 'me' else CONCAT(first_name,' ',last_name) end) text").order("first_name")
      data = @current_organization.users.where("invitation_token IS ? and is_active = ? and is_blocked = ?", nil, true, false).select("id value, (case when id = " + @current_user.id.to_s + " then 'me' else ( case when first_name IS NOT NULL and first_name != '' and last_name IS NOT NULL and last_name != '' then CONCAT(first_name,' ',last_name) else email end) end) text").order("first_name")
    else
      data = @current_organization.users.where("invitation_token IS ? and is_active = ? and is_blocked = ?", nil, true, false).select("id value, email text")
    end
    respond_to do |format|
      #format.html 
      format.json { render json: data.to_json }
    end
  end

  def get_daily_update_form
    if params[:deal_id].present?  
      deal = Deal.find_by_id params[:deal_id]
      if deal.present? && deal.daily_update.present?
        @daily_update = deal.daily_update
      else
        @daily_update = DailyUpdate.new()
      end
      users = []
      users << deal.assigned_user
      deal.tasks.map{|t|t.user}.each do |user|
        users << user
      end
      @users = users.uniq
      render :partial => "users/user_daily_updates"
    else
      render text: ""
    end
  end  

  def save_user_lead
    uemail = User.where(:id => params[:value]).first.email
    if uemail.present?
      TempLead.find(params[:name]).update_attribute(:assigned_to, uemail)

    end
    render text: 'success'
  end

  def get_task_type_lead
    data = @current_organization.task_types.select("name value, name text")

    respond_to do |format|
      #format.html 
      format.json { render json: data.to_json }
    end
  end


  def save_task_type_lead
    TempLead.find(params[:name]).update_attribute(:task_type, params[:value])
    render text: 'success'
  end


  def save_compsize_lead
    TempLead.find(params[:name]).update_attribute(:company_size, params[:value])
    render text: 'success'
  end

  def insert_deal_industry
    industry= Industry.new
    industry.organization = @current_organization
    industry.name = params[:value]
    if industry.save
      render json: {id: industry.id, name: industry.name}
    else
      msgs=industry.errors.messages
      render :text => "exists"
    end
  end

  def save_deal_industry

    if params[:pk] == "industry"
      deal = DealIndustry.where(:deal_id => params[:deal_id]).first
      if deal.present?
        deal.update_column :industry_id, params[:value]
      else
        DealIndustry.create(:organization => @current_organization, :deal_id => params[:deal_id], :industry_id => params[:value])
      end
      response_txt = Industry.get_name(params[:value]).to_json
    elsif params[:pk] == "source"
      deal = DealSource.where(:deal_id => params[:deal_id]).first
      if deal.present?
        deal.update_column :source_id, params[:value]
      else
        DealSource.create(:organization => @current_organization, :deal_id => params[:deal_id], :source_id => params[:value])
      end
      response_txt = Source.get_name(params[:value]).to_json
    end
    respond_to do |format|
      #format.html 
      format.json { render text: response_txt }
    end
    #render text: 'success' 
  end

  def reassign_user_to_deals
    p params[:reassign_deal_ids]
    p params[:reassigned_to]
    if params[:reassign_deal_ids].present? && params[:reassigned_to].present?
      if params[:reassign_deal_ids].include?(',')
        deal_ids=params[:reassign_deal_ids].chop
      else
        deal_ids=params[:reassign_deal_ids]
      end
      p deal_ids=deal_ids.split(",")
      p user=User.where(:id => params[:reassigned_to]).first
      if user.present?
        if (deals=Deal.where(:id => deal_ids)).first.present?
          deals.update_all(:assigned_to => user.id, :is_remote => 0)
          if !params[:reassign_deal_ids].include?(',')
            Deal.where(:id => deal_ids).update_all(:is_remote => 0)
          end
          deals.map { |deal| deal.reassign_actvity }
          #SendEmailNotificationDeal.perform_async(user.email, user.full_name, nil, nil, deal_ids, true)
        end
      end
    end
    render text: "success"
  end


  def quick_deal
    @deal = Deal.find params[:deal_id]
    render partial: "quick_edit"
  end

  def get_contact
    @deal = Deal.find(params[:dealid])
    if params[:individual] == 'true'
      @contact = IndividualContact.find(params[:contact_id])
    else
      @contact = CompanyContact.find(params[:contact_id])
    end
    @cat = @@category
    @work_phone = @contact.phones.by_phone_type "work"
    @mobile_phone = @contact.phones.by_phone_type "mobile"
    render partial: "shared/get_contact", :content_type => 'text/html'
  end

  def created_by_user
    #data = @current_organization.users.where("invitation_token IS ? and is_active = ?", nil,true).select("id value, email text")
    data = all_org_users
    @users = all_org_users
    data = @users.map do |u|
      {:id => u.id, :fname => u.full_name}
    end


    respond_to do |format|
      #format.html 
      format.json { render json: data.to_json }
    end
  end

  def deal_detail_contacts
    @deal = Deal.find params[:dealid]
    respond_to do |format|
      format.text { render partial: "deal_contacts" }
    end
  end

  def deal_files
    @attach = Note.where("notable_type =? and notable_id=?", "Deal", params[:dealid]).order("id desc")
    @deal = Deal.find params[:dealid]
    respond_to do |format|
      format.text { render partial: "files" }
    end
  end

  def delete_note_attachment
    @note_act = NoteAttachment.find(params[:id])
    @note_act.attachment.destroy
    @note_act.attachment= nil
    @note_act.save
    flash[:bosuccess] = "Attachment file has been deleted successfully."
    redirect_to request.referrer
  end

  def edit_note
    nt = Note.find params[:noteid]
    nt.update_attribute(:is_public, params[:note][:is_public])
    flash[:bosuccess] = "Privacy setting of the file has been saved successfully."
    redirect_to request.referrer
  end

  def deal_location_filter
    @country = Country.all
    data = @country.map do |c|
      {:id => c.id, :cname => c.name}
    end
    respond_to do |format|
      #format.html 
      format.json { render json: data.to_json }
    end
  end

  def change_assigned_to
    if (@deal = @current_organization.deals.where(:id => params[:id]).first).present?
      @deal.update_attributes(:assigned_to => params[:user_id], :last_activity_date => Time.zone.now, :is_remote => false)
      @deal.reassign_actvity
      # @deal.update_column :last_activity_date, Time.zone.now
      # @deal.update_column(:is_remote, false) #if (params[:type].present? && params[:type] == "unassigned")
      # if (user=User.where(:id => params[:user_id]).first).present?
      #   #SendEmailNotificationDeal.perform_async(user.email,user.full_name,nil,nil,deal.id, true)
      # end
      render partial:"opp_assigned_to"
    end
  end

  def edit_assigned_to
    if (@deal = @current_organization.deals.where(:id => params[:pk]).first).present?
      @deal.update_attributes(:assigned_to => params[:value], :last_activity_date => Time.zone.now, :is_remote => false)
      @deal.reassign_actvity
      # @deal.update_column :last_activity_date, Time.zone.now
      # @deal.update_column(:is_remote, false)
      render :text => @deal.assigned_to
    end
  end

  def assigned_deal_leaderboard
    user = User.find params[:user_id]
    if params[:type]=="open_leads"
      @deals = user.all_assigned_deal.by_is_active.where("is_won IS NULL").includes(:deal_status).by_range(params[:start_date].to_date,params[:end_date].to_date)

      #.by_range(params[:start_date].to_date, params[:end_date].to_date)
    else
      @deals = user.all_assigned_deal.by_is_active.where("created_at >= ? AND created_at <= ?",params[:start_date].to_date, params[:end_date].to_date)
    end
    #respond_to do |format|
    # #format.html
    #  format.js { render text: 'ss'}
    # end
    render :partial => "assigned_deal_leaderboard"
  end

  def upload_multiple_note_attach
    tf=TempFileUpload.create :user_id => current_user.id, :attachment => params[:myfile]
    respond_to do |format|
      format.json { render json: {:message => "success", :id => tf.id} }

    end
    #render :text =>{:message=>"success",:id=> tf.id}
  end

  def delete_temp_note_attach
    tf=TempFileUpload.find params[:tf_id]
    tf.destroy
    render text: "success"
  end


  def send_weekly_digest_email
    unless current_user.is_admin? || current_user.is_super_admin?
      flash[:bowarning]="It seems you don't have sufficient privilege to access this item or something went wrong with your account permissions.<br/> Please contact Admin to get this fixed."
      redirect_to root_path
      return
    else
     # SendWeeklyEmail.perform_async("#{current_user.organization_id}")
      flash[:bosuccess]="Mail sent successfully."
      redirect_to root_path
    end
  end

  def accept_assign_deal
    begin
      crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
      decrypted_lead_token = crypt.decrypt_and_verify(params[:hot_lead_token])
      user_id = crypt.decrypt_and_verify(params[:user_id])
      if (deal = Deal.where("hot_lead_token =?", decrypted_lead_token).first).present?
        cookies[:redirect_deal_id] = deal.id
        deal.update_attributes :assigned_to => user_id, :is_remote => false, :hot_lead_token => nil, :token_expiry_time => nil, :next_priority_id => nil, :assignee_id => nil
        flash[:bosuccess] = "Lead has been accepted successfully."
      else
        flash[:bodanger] = "Token has already been expired!"
      end
    rescue => e
      file = File.new("#{Rails.root}/log/accept_hot_lead.log", "a")
      file.puts 'Error while accepting' + ' ' + "executed on" + ' ' + Time.now.utc.to_s
      file.puts "Mesage:" + e.message.to_s
      file.puts "Mesage:" + e.backtrace.to_s
      file.puts "----------------------------------------> <----------------------------------------------"
      file.close
      p e.message
      flash[:bodanger] = "Invalid token!"
    end
    redirect_to root_path
  end

  def deny_assign_deal
    begin
      crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
      decrypted_lead_token = crypt.decrypt_and_verify(params[:hot_lead_token])
      user_id = crypt.decrypt_and_verify(params[:user_id])
      if (deal = Deal.where("hot_lead_token =?", decrypted_lead_token).first).present?
        start_process_of_assigning_deal deal.id, assigned_to=nil, hot_lead_token=nil, 'deny'
        flash[:bosuccess] = "You have successfully denied the request of accepting the lead."
      else
        flash[:bodanger] = "Token has already been expired!"
      end
    rescue => e
      file = File.new("#{Rails.root}/log/deny_hot_lead.log", "a")
      file.puts 'Error while denying' + ' ' + "executed on" + ' ' + Time.now.utc.to_s
      file.puts "Mesage:" + e.message.to_s
      file.puts "Mesage:" + e.backtrace.to_s
      file.puts "----------------------------------------> <----------------------------------------------"
      file.close
      p e.message
      flash[:bodanger] = "Invalid token!"
    end
    redirect_to root_path
  end

  def get_list_view
    render :partial => "show_list_view"
  end

  def get_kanban_view
    @deal_statuses = @current_organization.deal_statuses.where("name NOT IN (?)", ['won', 'lost']).order("original_id")
    cookies.delete(:open_all_type)
    cookies[:open_all_type] = params[:open_all_type]
    if params[:user_id].present?
      render :partial => "get_kanban_view"
    else  
      render :partial => "show_kanban_view"
    end
  end

  def delete_lead
    @deal = Deal.find(params[:id])
    if @deal.destroy
      render text: "Success", status: :ok
    else
      render text: "Fail", status: 406
    end
  end

  def get_deal_funnel
    deals_funnel_chart=[] #Deal.includes(:deal_status).where(:organization_id=>@current_organization.id).where("deals.deal_status_id IS NOT NULL AND deal_statuses.is_active=? AND deal_statuses.is_visible =?",true,true).group("deal_statuses.name").count
    deal_statuses = @current_organization.deal_statuses.where({is_active: true, is_visible: true, is_funnel_view: true})
    ds ={}
    colors = []
    i = 0
    # arr = deal_statuses.map(&:name)
    # arr.each { |num| ds[num] = (ds[num] || 0) + 0 }
    deal_statuses.each do |deal_status|
      tab_deal = {deal_status.name => Deal.where("deal_status_id=?", deal_status.id).count}
      deals_funnel_chart << tab_deal
      colors << (deal_status.color.present? ? deal_status.color : DealsHelper::COLORS[i])
      i += 1
    end
    deal_statuses_for_funnel = ds.merge(deals_funnel_chart.reduce(:merge))
    #colors = deal_statuses_for_funnel.length.times.map{'#' + "%06x" % rand(0..0xffffff)}
    ds_array =[]
    deal_statuses_for_funnel.each do |key, value|
      ds_array << [key, value]
    end
    #{"New"=>0, "Qualified"=>0, "Not Qualified"=>0, "Quote"=>0, "Won"=>0, "Lost"=>0, "Returning"=>0, "Last"=>0, "overload"=>0, "break"=>1}
    @funnel_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({type: 'funnel', marginRight: 70})
      #f.title({ text: 'Sales funnel', x: -50})
      #f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
      f.colors(colors)
      f.plotOptions(
          series: {
              dataLabels: {
                  enabled: true,
                  format: '<b>{point.name}</b> ({point.y:,.0f})',
                  color: 'black',
                  softConnector: true
              },
              neckWidth: '10%',
              neckHeight: '-10%',
              height: '90%',

          })
      f.legend({enabled: true})
      f.series({
                   name: 'count',
                   data: ds_array
               })
    end
    render :partial => "deal_funnel_chart"
  end

  def create_lead_ticket
    api_integration = @current_organization.api_integrations.where({api_name: 'Zendesk'}).first
    if api_integration
      @zendesk_client = initialize_zendesk_api_client(api_integration)
      deal = Deal.find(params[:id])
      resp = @zendesk_client.tickets.create!(:subject => deal.title, :comment => {:value => 'This is a test'}, :submitter_id => @zendesk_client.current_user.id, :priority => 'urgent')
      if resp
        render json: {message: 'Success', status: 200}, status: 200
      else
        render json: {message: 'Fail', status: 500}, status: 500
      end
    else
      render json: {message: 'Fail', status: 406}, status: 406
    end
  end
  # Change the status of lead in kanban view in drag and drop effect.
  def change_lead_status
    begin
      status = @current_organization.deal_statuses.find_by_name(params[:status])
      lead = @current_organization.deals.find_by_id(params[:lead_id])
      lead.update_attribute :deal_status_id, status.id
      params[:user_id] = params[:user_id]=="All" ? "" : params[:user_id]
      @deal_statuses = @current_organization.deal_statuses.where("name NOT IN (?)", ['won', 'lost']).order("original_id")
      #render :text => "Deal stage changed successfully!"
      render partial: "get_kanban_view"
    rescue
    end
  end
  def get_lead_details_in_lead_listing
    @lead = Deal.find(params[:id])
    render partial: "fetch_lead_details"
  end
  def change_priority
    begin
      @priority_type = @current_organization.priority_types.where(original_id: params[:priority_id]).first
      @lead = @current_organization.deals.find(params[:id])
      @lead.update_attributes :priority_type_id => @priority_type.id
      render text: @priority_type.name
    rescue Exception => e
      render text: e.message
    end
  end
  # Change the user label in lead listing page(Uncetegorised, Inbound or Outbound)
  def change_user_label
    @lead = @current_organization.deals.find(params[:id])
    user_lbl = @current_organization.user_labels.where( name: params[:user_label_name] ).last
    @lead.update_attributes :user_label_id => user_lbl.id if user_lbl.present?
    render text: @lead.user_label.name
  end
  # Change the deal source in lead details
  def change_deal_source
    deal_source = @current_organization.deal_sources.where("deal_id=?", params[:id]).first
    if deal_source.present?
      deal_source.update_column(:source_id, params[:source_id])
    end
    render text: deal_source.source.name
  end
  # Get all lead stages in lead listing page and lead details page.
  def get_lead_stages
    if params[:page].present?
      @page = params[:page]
    else
      @page = "lead_listing"
    end
    @lead = @current_organization.deals.find(params[:id])
    render partial: "get_stages"
  end
  # change lead stage in lead listing page.
  def change_lead_stage
    @deal = @current_organization.deals.find(params[:id])
    deal_status = @current_organization.deal_statuses.where("id =?", params[:stage_id]).first
    if deal_status.name.present?
      if deal_status.name.downcase == "won"
        @deal.update_attributes(is_won: true, closed_date: DateTime.now)
        render text: "Won"
      elsif deal_status.name.downcase == "lost"
        @deal.update_attributes(is_won: false, closed_date: DateTime.now)
        render text: "Lost"
      else
        @deal.update_attributes(deal_status_id: params[:stage_id], is_won: '', lost_reason: '', closed_date: '' )
        render text: "#{@deal.deal_status.name}"
      end
    end
  end
  # change lead stage in lead details page.
  def change_lead_stage_in_lead_details
    @deal = @current_organization.deals.find(params[:id])
    deal_status = @current_organization.deal_statuses.where("id =?", params[:stage_id]).first
    if deal_status.name.present?
      if deal_status.name.downcase == "won"
        @deal.update_attributes(is_won: true, closed_date: DateTime.now)
      elsif deal_status.name.downcase == "lost"
        @deal.update_attributes(is_won: false, closed_date: DateTime.now)
      else
        @deal.update_attributes(deal_status_id: params[:stage_id], is_won: '', lost_reason: '', closed_date: '' )
      end
    end
    render partial: "opp_status_bar"
  end
  # change lead payment type in lead details page.
  def change_Payment_type_in_lead_details
    lead = @current_organization.deals.where("id=?", params[:id]).first
    lead.update_attributes(payment_status: params[:status])
    render text: "#{lead.payment_status}"
  end
  def delete_emails
    mail_letters = MailLetter.where("id IN (?)", params[:ids].split(","))
    activities = mail_letters.map{|m|m.mailable.activities.where("activity_type=?","MailLetter")}.flatten
    email_opens = SentEmailOpen.where("activity_id IN (?)", activities.map(&:id))
    mail_letters.map{|mail_letter| mail_letter.destroy}
    email_opens.map{|email_open| email_open.destroy}
    render :json => "success"
  end
  def archive_emails
    mail_letters = MailLetter.where("id IN (?)", params[:ids].split(","))
    mail_letters.map{|mail_letter| mail_letter.update_attributes(is_archived: true)}
    render :json => "success"
  end

  def get_kanban_stages
    @deal_statuses = @current_organization.deal_statuses
    render partial: "get_kanban_stages"
  end
  # Display or hide the stages in kanban
  def tab_settings_in_kanban
    @deal_statuses_true = @current_organization.deal_statuses.where(id: params[:hdn_stage].split(','))
    @deal_statuses_true.each do |deal_status|
      deal_status.update_attributes(is_kanban: true)
    end
    @deal_statuses_false = @current_organization.deal_statuses.where("id NOT IN (?)", params[:hdn_stage].split(','))
    @deal_statuses_false.each do |deal_status|
      deal_status.update_attributes(is_kanban: false)
    end
    @deal_statuses = @current_organization.deal_statuses.where(is_kanban: true)
    render partial: "get_kanban_view"
  end

  def get_lead_opportunity
    if params[:id].present?  
      contact = @current_organization.individual_contacts.where("id=?",params[:id]).first
      deals="<option value=''>Choose the opportunity you want to link with...</option>"
      p contact.deals_contacts
      contact.deals_contacts.order("id desc").each do |dc|
        if dc.present? && dc.deal.present? && dc.deal.is_active == true && dc.deal.is_won == nil
          deals += "<option value='" + dc.deal.id.to_s + "'>" + dc.deal.title + "</option>"
        end
      end
      render :json => deals
    else
      render text: ""
    end
  end

  def edit_deal_note
    @note = @current_organization.notes.where("id=?",params[:id]).first
    @deal = @current_organization.deals.where("id=?",@note.notable_id).first
    render partial:"edit_note_form"
  end
  def update_deal_note
    note = @current_organization.notes.where("id=?",params[:id]).first
    note.update_attributes({title: params[:note][:title],notes: params[:note][:notes],note_type_id: params[:note][:note_type_id]})
    flash[:notice] = "Note has been updated successfully"
    redirect_to request.referrer
  end
  def delete_deal_note
    note = @current_organization.notes.where("id=?",params[:id]).first
    note.destroy
    activity = Activity.where("activity_type=? AND activity_id=?", "Note", note.id).first
    activity_id = activity.id
    activity.destroy
    render text: activity_id 
  end

  def opportunity_widget
    @deal = @current_organization.deals.where("id=?", params[:id]).first
    if params[:tab_type] == "quick_notes"
      query_condition=[]
      query_condition.where("deals.id = ? and deals.organization_id=?", params[:id], @current_organization.id)
      org_notes = @current_organization.notes.where(notable_type: "Deal", notable_id: params[:id]).order("created_at desc")
      @notes=[]
      org_notes.each do |note|
        @notes << note if note.title.present?
      end
      @note = Note.new()
      unless @current_user.is_admin? || @current_user.is_super_admin?
        query_condition.where("(is_public=? OR (deals.assigned_to=? OR deals.initiated_by=?))", true, @current_user.id, @current_user.id)
      end
      render partial: "opp_quick_notes"
    elsif params[:tab_type] == "task_list"
      @tasks = @deal.tasks.order("updated_at DESC")
      render partial: "opp_task_list"
    elsif params[:tab_type] == "activity_stream"
      render partial: "time_line_stream"
    elsif params[:tab_type] == "emails"
      render partial: "opp_emails"
    elsif params[:tab_type] == "invoices"
      if @deal.deals_contacts.present? && @deal.deals_contacts.first.contactable.present?
        @contact = @deal.deals_contacts.first.contactable
      end
      @invoices = @deal.invoices.where(invoice_type: "invoice").order("created_at desc")
      render partial: "opp_invoices"
    elsif params[:tab_type] == "quotes"
      if @deal.deals_contacts.present? && @deal.deals_contacts.first.contactable.present?
        @contact = @deal.deals_contacts.first.contactable
      end
      @quotes = @deal.invoices.where(invoice_type: "quote").order("created_at desc")
      render partial: "opp_quotes"
    elsif params[:tab_type] == "projects"
      @projects = @deal.projects.order("created_at desc")
      render partial: "projects/project_board_view"
    elsif params[:tab_type] == "upload_files"
      org_notes = @current_organization.notes.where(notable_type: "Deal", notable_id: params[:id]).order("created_at desc")
      @notes=[]
      org_notes.each do |note|
        @notes << note if note.note_attachments.present?
      end
      @note = Note.new()
      render partial: "opp_upload_files"
    else
      render text:"Some error has been occured, please contact to support."
    end
  end

  def change_opp_visibility
    deal = @current_organization.deals.where("id =?", params[:id]).first
    if deal.present?
      deal.update_attribute :is_public, params[:is_public] == 'true' ? true : false
      p "------update success-------"
    end
    render text: "success"
  end

  def create_email_note
    EmailNote.create(:organization_id => @current_organization.id, :user_id => @current_user.id, :mail_letter_id => params[:mail_letter_id], :notes => params[:notes])
    render text: "success"
  end
  def update_lead_to_won
    @deal = @current_organization.deals.where("id=?", params[:id]).first
    if @deal.present?
        @deal.update_attributes({:is_won => true, :lost_reason => "", :lost_comment => "", closed_date: DateTime.now})
        deal_status = @current_organization.deal_statuses.where("lower(name) NOT IN (?)", ['won', 'lost']).order("original_id").last
        if deal_status.present?
          @deal.update_attributes :deal_status_id => deal_status.id
        end
        # deal_stages = @current_organization.deal_statuses.where("id > ?", @deal.deal_status_id).first
        # puts "------------------ deal_stages:#{deal_stages.count}"
        # deal_stages.each do |stage|
        #   DealTransaction.create({:organization_id => @current_organization.id, :deal_id => @deal.id, :deal_status_id => stage.id, :user => User.current, :is_activity_display => false, :assigned_to => @deal.assigned_to.present? ? @deal.assigned_to : User.current.id})
        # end
        @user = User.find_by_id @deal.assigned_to
        if @user.present? && @user.goals.present?
          @user.goals.each do |gl|
            if gl.goal_type == 'quantity of deals won'
              UserGoal.create(:user_id=>@user.id,:goal_id => gl.id,:deal_id => @deal.id)
            end
            if gl.goal_type == 'value of deals won'
              UserGoal.create(:user_id=>@user.id,:goal_id => gl.id,:deal_id => @deal.id,:amount => @deal.amount)
            end
          end
        end
        render partial:"opp_status_bar"
    else
      render text:"fail"
    end
  end

  def update_lead_to_lost
    @deal = @current_organization.deals.where("id=?", params[:deal_id]).first
    if @deal.present?
      if params[:custom_reason].present? && params[:custom_reason] != nil && params[:custom_reason] != ""
        @deal.update_attributes({:is_won => false, :lost_reason => params[:custom_reason], :lost_comment => params[:lost_comment], closed_date: DateTime.now})
      else
        @deal.update_attributes({:is_won => false, :lost_reason => params[:lost_reason], :lost_comment => params[:lost_comment], closed_date: DateTime.now})
      end
      render partial:"opp_status_bar"
    else
      render text:"fail"
    end
  end

  def update_lead_expected_close_date   
    @deal = @current_organization.deals.where("id=?", params[:id]).first
    if @deal.present?
      @deal.update_column(:expected_close_date, params[:expected_close_date].to_date )
    end
    render text: @deal.expected_close_date.strftime("%B %d, %Y")
  end
  private

  def decrypt_id
    begin
      params[:id] = Deal.to_decrypt_key  params[:id]
    rescue => e
    end
  end
end