class ProjectController < ApplicationController
  def index 
    @projects = Project.all
  end

  def new 
    @project = Project.new
  end

  def create 
    
    puts "IP params : #{params}"
    new_project = Project.new(project_params)
    new_project.save

    @projects = Project.all
    redirect_to root_path
  end

  private 
    def project_params 
      params.require(:project).permit(:title, :client, :project_type)
    end
end
