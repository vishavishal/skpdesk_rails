class ProjectController < ApplicationController
  before_action :get_all_projects, only: [:index, :create]

  def index 
  end

  def new 
    @project = Project.new
  end

  def create 
    new_project = Project.new(project_params)
    puts "New project : #{new_project} : #{new_project.errors.inspect}"
    if new_project.valid?
      new_project.save
      redirect_to root_path
    else
      redirect_to project_new_path
    end
  end

  private 
    def get_all_projects
      @projects = Project.all.sort_by(&:created_at).reverse
    end
    
    def project_params 
      params.require(:project).permit(:title, :client, :project_type)
    end
end
