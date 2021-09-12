class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource_or_scope)
    puts "VGLOG : after sign in"
    projects_path
  end
  
  def after_sign_out_path_for(resource_or_scope)
    puts "VGLOG : after sign out"
    project_new_path
  end
end
