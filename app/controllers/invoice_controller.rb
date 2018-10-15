require 'net/http'
require 'open-uri'
#require 'FileUtils'
class InvoiceController < ApplicationController
  before_filter :authenticate_admin
  def test
    Payday::Config.default.invoice_logo = "public/image/wakeup-salelogo.png"
    Payday::Config.default.company_name = "WakeUpSales"
    Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nawesome@awesomecorp.com"
    invoice = Payday::Invoice.new(:invoice_number => 12)
    invoice.line_items << Payday::LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
    invoice.line_items << Payday::LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
    invoice.line_items << Payday::LineItem.new(:price => 5, :quantity => 200, :description => "Hats")
    send_data invoice.render_pdf, :filename => "Invoice #12.pdf", :type => "application/pdf", :disposition => "inline"
    #respond_to do |format|
    #  format.html
    #  format.pdf do
    #    send_data invoice.render_pdf, :filename => "Invoice #12.pdf", :type => "application/pdf", :disposition => "inline"
    #  end
    #end
  end
  def manage_invoice
    @invoices = @current_organization.invoices.where(invoice_type: "invoice").order("id DESC")
    #@title = "InSet CRM | Free CRM Tool | Manage Invoice"
    @description = "At InSet CRM the free crm tool, registered user can manage invoices as per their requirement."
  end

  def index

    if params[:type].present? && params[:type] == "quote"
      @invoice_type = "quote"
    else
      @invoice_type = "invoice"
    end
    @pre_invoice = @current_organization.invoices.last
    @invoice = @current_organization.invoices.new

    puts "last invoice............................."
    p @pre_invoice
    if(@pre_invoice.present?)
      invoice_no = @pre_invoice.invoice_no.to_i
      @invoice.invoice_no = invoice_no > 10000 ? (@pre_invoice.invoice_no.to_i + 1).to_s : "10000"
    else
      @invoice.invoice_no = "10000"
    end
    if params[:contact].present? && params[:lead].present?
      if params[:project].present?
        @project = Project.find(params[:project])
      end
      params[:contact_id] = IndividualContact.to_decrypt_key params[:contact]

      @contact = @current_organization.individual_contacts.where("id=?", params[:contact_id]).first
      params[:deal_id] = Deal.to_decrypt_key params[:lead]
      @deal = Deal.find_by_id(params[:deal_id])
      if(@deal.present? )
        @projects = @deal.projects
      end
    end
    @invoice_items = @invoice.invoice_items.build
    @cur = @@currencies
    #@title = "InSet CRM | Free CRM Tool | Manage Invoice"
      @description = "At InSet CRM the free crm tool, registered user can manage invoices as per their requirement."
  end

  def activate_quote
    if params[:id].present?
      invoice = Invoice.find_by_id(params[:id])
      if invoice.present? && invoice.invoice_type == "quote"
        if invoice.update_attributes(is_active: true)
          quotes = invoice.deal.invoices.where("id != ? AND invoice_type = 'quote'", invoice.id)
          if quotes.present?
            quotes.update_all(is_active: false)
          end
          flash[:notice] = "The quote has been activated successfully!"
        end 
      end
    end 
    redirect_to :back
  end

  def invoice_from_quote
    @cur = @@currencies
    if params[:id].present?
      @invoice = Invoice.find_by_id(params[:id])
      @pre_invoice = @current_organization.invoices.last
      @invoice_items = @invoice.invoice_items
      @contact = @current_organization.individual_contacts.where("id=?",@invoice.contact_id).first
      if @invoice.deal_id.present?
        @deal = Deal.find_by_id(@invoice.deal_id)
        if(@deal.present? )
          @projects = @deal.projects
        end
      end
      if(@pre_invoice.present?)
        invoice_no = @pre_invoice.invoice_no.to_i
        @invoice.invoice_no = invoice_no > 10000 ? (@pre_invoice.invoice_no.to_i + 1).to_s : "10000"
      else
        @invoice.invoice_no = "10000"
      end
      @invoice_type = "invoice"
      if !@invoice.invoice_items.present? 
        @invoice_items = @invoice.invoice_items.build
      end
    end
    render template: "invoice/index"   
  end

  # def convert_quote_to_invoice
  #   if params[:id].present?
  #     invoice = Invoice.find_by_id(params[:id])
  #     if invoice.invoice_type == "quote" && invoice.is_active
  #       if invoice.update_attributes(invoice_type: "invoice")
  #         status = "success"
  #         flash[:notice] = "The quote has been converted to invoice and moved to invoice tab!"
  #       end
  #     end
  #   end
  #   redirect_to "/leads/#{invoice.deal.to_param}"
  # end

  def create_invoice
    if params[:invoice][:contact_id].present?
      if params[:invoice][:contact_type] == "IndividualContact"
        @contact = @current_organization.individual_contacts.find_by_id(params[:invoice][:contact_id])
        #else
        # @contact = CompanyContact.find_by_id(params[:invoice][:contact_id])
      end
      @contact_id = @contact.id
      if params[:invoice][:due_date].present?
        params[:invoice][:due_date] = Date.strptime(params[:invoice][:due_date], "%m/%d/%Y")
      end
      if params[:invoice][:start_date].present?
        params[:invoice][:start_date] = Date.strptime(params[:invoice][:start_date], "%m/%d/%Y")
      end
      if params[:invoice][:end_date].present?
        params[:invoice][:end_date] = Date.strptime(params[:invoice][:end_date], "%m/%d/%Y")
      end
      @invoice = @current_organization.invoices.create({user_id: current_user.id, 
        contact_id: @contact_id, 
        contact_type: params[:invoice][:contact_type], 
        currency: params[:currency_type][:type], 
        invoice_no: params[:invoice][:invoice_no], 
        due_date: params[:invoice][:due_date], 
        cc_mail_id: params[:invoice][:cc_mail_id], 
        notes: params[:invoice][:notes], 
        terms_and_condition: params[:invoice][:terms_and_condition], 
        transaction_date: Time.new, 
        company_name:  params[:invoice][:company_name], 
        deal_id: params[:deal_id], 
        tax: params[:invoice][:tax], 
        company_address:  params[:invoice][:company_address], 
        tax:  params[:invoice][:tax], 
        total_amount: params[:total_payable_amount].to_f,
        discount:  params[:invoice][:discount].to_f, 
        po_number: params[:invoice][:po_number],
        project_id: params[:invoice][:project_id],
        start_date: params[:invoice][:start_date],
        end_date: params[:invoice][:end_date],
        invoice_type: params[:invoice][:invoice_type]
        }
        )

      if params[:invoice][:image].present?
        @invoice.image = Image.create!( :organization => @current_organization, :imagable => @invoice, :image => params[:invoice][:image] )
          url = @invoice.image.image.url(:small)
        else
          if (pre_invoice = @current_organization.invoices).present? && (last_invoice_logo = pre_invoice.where("logo_url is NOT NULL and logo_url != ''").last).present?
            url = last_invoice_logo.logo_url
          else
            url = nil
          end
        end
        @invoice.update_column(:logo_url, url)

      if @invoice
        if @invoice.logo_url.present?
          download = open(url)
          IO.copy_stream(download, "public/logo_#{@invoice.id}.png")
          logo_path = "public/logo_#{@invoice.id}.png"
        end
        if @invoice.invoice_type == "invoice"
          if logo_path.present?
            Payday::Config.default.invoice_logo = logo_path
          else
            Payday::Config.default.invoice_logo = "public/default_logo.png"
          end
          Payday::Config.default.currency = params[:currency_type][:type]
          Payday::Config.default.company_name = params[:invoice][:company_name]
          Payday::Config.default.company_details = params[:invoice][:company_address]
        end
        
        @invoice_items=[]
        params[:invoice][:invoice_items_attributes].each do |t|
          if(t[1]["amount"] !="" && t[1]["description"] != "" && t[1]["qty"] != "")
            @invoice_items << @invoice.invoice_items.create({
              :amount => t[1]["amount"],
              :qty => t[1]["qty"],
              :rate => t[1]["rate"],
              :description => t[1]["description"],
              :job_time_log_id => t[1][:job_time_log_id]}
              )
          end
        end
        # @invoice_item = @invoice.invoice_items.create(description: params[:description], amount: params[:amount])

        if @invoice.invoice_type == "invoice"
          pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => params[:invoice][:notes], :tax_rate => params[:invoice][:tax].present? ? ("%.3f" % (params[:invoice][:tax].to_f / 100.0)) : "")
          @invoice_items.each do |item|
            pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
          end
        end
      end
      if params[:invoice][:is_sent].to_s == "true"
        if is_valid_user_email @contact.email
          Notification.send_invoice_email(@contact.email,params[:invoice][:cc_mail_id], @current_organization.name, @invoice,@invoice_items,"",pd_invoice).deliver
          @invoice.update_attributes status: "Sent", is_sent: true
          flash[:success] = "#{@invoice.invoice_type.capitalize} has been sent successfully."
        else
          @invoice.update_attributes status: "Yet to Send", is_sent: false
          flash[:alert] = "It seems to be your email id is not valid."
        end
      else
        @invoice.update_attributes status: "Yet to Send", is_sent: false
        flash[:success] = "#{@invoice.invoice_type.capitalize} has been saved successfully."
      end
      File.delete(logo_path) if logo_path.present? && File.exist?(logo_path)
      if params[:referrence_page].present? && params[:referrence_page] == "deal"
        redirect_to "/leads/#{@invoice.deal.to_param}"
      elsif params[:referrence_page].present? && params[:referrence_page] == "project"
        redirect_to "/projects/#{@invoice.project_id}"
      else
        redirect_to "/manage_invoice"
      end
      if @invoice.invoice_type == "quote"
        quotes = @invoice.deal.invoices.where("id != ? AND invoice_type = 'quote'", @invoice.id)
        if quotes.present?
          quotes.update_all(is_active: false)
        end
      end
    else
      flash[:bowarning] = "Bill to address is incorrect! Make sure to select address from auto suggest."
      redirect_to "/invoice/create"
    end
  end

  def invoice_details
    @cur = @@currencies
    if params[:id].present?
      @invoice = Invoice.find_by_id(params[:id])
      @pre_invoice = @current_organization.invoices.last
      @invoice_items = @invoice.invoice_items
      @contact = @current_organization.individual_contacts.where("id=?",@invoice.contact_id).first
      if @invoice.deal_id.present?
        @deal = Deal.find_by_id(@invoice.deal_id)
      end
      if @invoice.invoice_type == "quote"
        @invoice_type = "quote"
      else
        @invoice_type = "invoice"
      end
    end
  end

  def resend_invoice
    if @contact.present? && @contact.email.present? 
      if is_valid_user_email @contact.email
        @invoice = @current_organization.invoices.find_by_id(params[:id])   
        generate_invoice_company
        if @invoice.is_sent
          @invoice.update_column :status, "Resend"
          message ="#{@invoice_type.capitalize} has been re-send successfully."
          Notification.send_invoice_email(@contact.email,@invoice.cc_mail_id, @current_organization.name, @invoice,@invoice_items,"Reminder for your Payment", @pd_invoice).deliver
        else
          @invoice.update_attributes :status => "Sent", :is_sent => true
          message ="#{@invoice_type.capitalize} has been sent successfully."
          Notification.send_invoice_email(@contact.email,@invoice.cc_mail_id, @current_organization.name, @invoice,@invoice_items,"", @pd_invoice).deliver
        end
        # if @invoice
        #   pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => @invoice.notes)
        #   #pd_invoice.line_items << Payday::LineItem.new(:price => @invoice_item.amount, :quantity => 1, :description => @invoice_item.description)
        #   @invoice_items.each do |item|
        #     pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
        #   end
        # end

        File.delete(@logo_path) if @logo_path.present? && File.exist?(@logo_path)
        flash[:notice] = message
      end
    else
      flash[:alert] = "It seems to be your email id is not valid."
    end
    redirect_to :back
  end


  def paid_invoice
    @invoice = @current_organization.invoices.find_by_id(params[:id])   
    @invoice.update_attribute :status, "Paid"
    @invoice.save
    generate_invoice_company

    # if @invoice
    #   pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => @invoice.notes, :paid_at => @invoice.updated_at.strftime("%m-%d-%Y"))
    #   #pd_invoice.line_items << Payday::LineItem.new(:price => @invoice_item.amount, :quantity => 1, :description => @invoice_item.description)
    #   @invoice_items.each do |item|
    #     pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
    #   end
    # end

    if params[:type].present? 
      if is_valid_user_email @contact.email   
        Notification.send_invoice_paid_email(@contact.email, @invoice.cc_mail_id, @current_organization.name, @invoice, @invoice_items,@pd_invoice).deliver
        File.delete(@logo_path) if @logo_path.present? && File.exist?(@logo_path)
        flash[:notice] = "Invoice has been marked as paid."
      else
        flash[:alert] = "It seems to be your email id is not valid."
      end
    end
    redirect_to :back
  end


  def cancel_invoice
      @invoice = @current_organization.invoices.find_by_id(params[:id])
      @invoice_items = @invoice.invoice_items
      @contact = @current_organization.individual_contacts.find_by_id(@invoice.contact_id)
      @invoice.update_column :status, "Cancelled"
    if is_valid_user_email @contact.email
      if @invoice.is_sent 
        Notification.send_invoice_cancel_email(@contact.email, @invoice.cc_mail_id, @current_organization.name, @invoice, @invoice_items).deliver
      end
      flash[:notice] = "#{@invoice_type.capitalize} has been Cancelled."
    else
      flash[:alert] = "It seems to be your email id is not valid."
    end
    redirect_to :back
  end

  def get_invoice_deal_projects
    @deal = @current_organization.deals.where("id=?", params[:id]).first
    @projects = @deal.projects.order("created_at desc")
    render partial: "invoice/get_invoice_deal_projects"
  end

  def get_bill_to_details
    @cont_type = params[:cont_type]
    @cont_id = params[:cont_id]
    @contact = @current_organization.individual_contacts.where("id=?",@cont_id).first
    @deals=[]
      @contact.deals_contacts.order("id desc").each do |dc|
        @deals << dc.deal if dc.present?
      end
    render :partial=> "invoice/show_bill_to_details"
  end
  def download_invoice
    @invoice = @current_organization.invoices.find_by_id(params[:id])   
    generate_invoice_company
    
    #path_to_file = "#{Rails.root}/public/invoices/pd_invoice_#{@invoice.id}.pdf"
    #pd_invoice.render_pdf_to_file(path_to_file)    
    
    #send_data (path_to_file), :type => 'application/pdf'
    send_data @pd_invoice.render_pdf, :filename => "#{@invoice.company_name.gsub(' ','_')}_#{@invoice.invoice_no}.pdf", :type => "application/pdf"
    File.delete(@logo_path) if @logo_path.present? && File.exist?(@logo_path)
  end
  def generate_invoice_company
    @invoice_items = @invoice.invoice_items
    @contact = @current_organization.individual_contacts.find_by_id(@invoice.contact_id)
    
    if (url=@invoice.logo_url).present?
      download = open(url)
      IO.copy_stream(download, "public/logo_#{@invoice.id}.png")
      @logo_path = "public/logo_#{@invoice.id}.png"
    end
    if @logo_path.present?
      Payday::Config.default.invoice_logo = @logo_path
    else
      Payday::Config.default.invoice_logo = "public/default_logo.png"
    end
    Payday::Config.default.currency = @invoice.currency
    Payday::Config.default.company_name = @invoice.company_name
    Payday::Config.default.company_details = @invoice.company_address
    if @invoice
      @pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => @invoice.notes, :paid_at => @invoice.status.downcase == "paid" ? @invoice.updated_at.strftime("%m-%d-%Y") : nil, :tax_rate => @invoice.tax.present? ? ("%.3f" % (@invoice.tax.to_f / 100.0)) : "")
      #pd_invoice.line_items << Payday::LineItem.new(:price => @invoice_item.amount, :quantity => 1, :description => @invoice_item.description)
      @invoice_items.each do |item|
        @pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
      end
    end   
  end

  def check_unique_invoice
    render json: @current_organization.invoices.where("invoice_no=?",params[:invoice_no]).first.present?
  end
  def get_invoice_line_items
    start_date = DateTime.strptime(params[:start_date],"%m-%d-%Y")
    end_date = DateTime.strptime(params[:end_date],"%m-%d-%Y")
    project_id = params[:project_id]
    @project = Project.where(:id=>params[:project_id]).first
    p start_date.to_date
    job_time_logs = @project.job_time_logs.where("log_start_time between ? and ? or log_end_time between ? and ?",start_date.strftime("%Y-%m-%d"),end_date.strftime("%Y-%m-%d"),start_date.strftime("%Y-%m-%d"),end_date.strftime("%Y-%m-%d")).where("job_time_logs.id not in (select distinct COALESCE( job_time_log_id,0) from invoice_items where invoice_id not in(select id from invoices where status = 'Cancelled'))").where("job_time_logs.is_billable = true").all
    p @project
    p job_time_logs
    render json: job_time_logs.map{|jtl| {job_time_log_id: jtl.id, note: "#" + jtl.project_job.job_no.to_s + ": " +  jtl.project_job.name + (jtl.note.present? ?   "\n" + ActionController::Base.helpers.strip_tags(jtl.note) : ""),spent_hours: (jtl.spent_hours / 3600), billable_hrs: jtl.user.user_hourly_billable.present? ? jtl.user.user_hourly_billable.amount : 0}}
  end
end
