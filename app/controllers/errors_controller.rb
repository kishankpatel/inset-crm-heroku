class ErrorsController < ApplicationController
  layout "error"
  skip_before_filter :authenticate_user!
  def error_404
    layout false 
    @not_found_path = params[:not_found]
    
    respond_to do |format|
      format.html { render "error_404", :layout => ""  } 
    end
  end

  def error_500
    layout false
  end
  def error_422
    layout false
  end
  def render_error
    p response.status
    puts "rending error .................."
    respond_to do |format|
      if(status == 404)
        format.html { render template: "errors/error_#{status}", layout: 'layouts/homer', status: status }
      else
        format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status }
      end
      format.all { render nothing: true, status: status }
    end
  end
end