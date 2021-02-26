class ProjectsController < ApplicationController
  def index
  	@projects = Project.all
  	@project = Project.new
  end

  def new
    @project = Project.new
    @collection = [1, 2, 3]
  end

  def create
    @project = Project.new(project_params)
  	@project.save ? redirect_to(projects_path) : render(:new)
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    @project.update(project_params)
    redirect_to edit_project_path(@project)
  end

  private

  def project_params
    params.require(:project).permit(abyme_attributes, :title, :description)
  end
end
