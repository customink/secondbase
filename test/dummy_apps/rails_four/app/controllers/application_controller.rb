class ApplicationController < ActionController::Base

  def index
    render :html => '<h1>Dummy::Application</h1>'.html_safe, :layout => false
  end

end
