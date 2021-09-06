class ProjectController < ApplicationController
  def index 
    @projects = Project.all
  end

  def new 
    @project = Project.new
  end

  def create 
    new_project = Project.new(project_params)
    new_project.save
  end

  private 
    def project_params 
      
    end
end
