class ApplicationController < ActionController::Base
  protect_from_forgery
  
    layout Proc.new { |controller| controller.devise_controller? ? 'empty' : 'application' }
    
    def after_sign_in_path_for(resource)
      binding.pry
      if(request.referrer =~ /register|login|\/users/)
        root_path
      else
        request.referrer
      end
    end
    
    def after_sign_out_path_for(resource)
      request.referrer
    end
end
