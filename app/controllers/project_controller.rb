class ProjectController < ApplicationController
  before_action :get_all_projects, only: [:index, :create]

  def index 
  end

  def new 
    @project = Project.new
  end

  def create 
    proj_h = project_params 
    proj_h[:designer_email] = current_user.email
    @project = Project.new(proj_h)
    puts "New project : #{@project} : #{proj_h}"
    if @project.valid?
      @project.save
      redirect_to root_path
    else
      flash[:notice] = @project.errors.full_messages.first
      redirect_to project_new_path
    end
  end

  private 
    def get_all_projects
      #@projects = Project.all.sort_by(&:created_at).reverse
      @projects = Project.where(designer_email: current_user.email)
    end
    
    def project_params 
      params.require(:project).permit(:title, :client, :project_type)
    end
end
