require 'will_paginate/array'
class TrackEmailsController < ApplicationController
  def index
  	begin
      @sent_emails = @current_organization.activities.where("activity_type=?","MailLetter").map {|a| a.sent_email_opens.first}.flatten.compact
      @mail_letters = @sent_emails.paginate(:page => params[:page], :per_page => 10)#.paginate(:page => page, :per_page => perpage)
      @email_opened = @sent_emails.count
      @email_unopened = (@current_organization.mail_letters.count - @email_opened)

      @opened_percentage = ((@email_opened.to_f / @current_organization.mail_letters.count.to_f) * 100.0).round
    	@unened_percentage = ((@email_unopened.to_f / @current_organization.mail_letters.count.to_f) * 100.0).round
    	@mail_day = @sent_emails.select{|m| (m.created_at.in_time_zone(@current_user.time_zone).hour >= 6 && m.created_at.in_time_zone(@current_user.time_zone).hour <= 12) ||  (m.created_at.in_time_zone(@current_user.time_zone).hour >= 12 && m.created_at.in_time_zone(@current_user.time_zone).hour < 18)}.count
      @mail_night = @email_opened - @mail_day #@sent_emails.select{|m| (m.created_at.in_time_zone(@current_user.time_zone).hour >= 18 && m.created_at.in_time_zone(@current_user.time_zone).hour < 24) ||  (m.created_at.in_time_zone(@current_user.time_zone).hour >= 1 && m.created_at.in_time_zone(@current_user.time_zone).hour < 7)}.count
    rescue
      @sent_emails = []
      @email_opened = []
      @email_unopened = 0
      @opened_percentage = 0
      @unened_percentage = 0
      @mail_day = 0
      @mail_night = 0
    end
  end
end
