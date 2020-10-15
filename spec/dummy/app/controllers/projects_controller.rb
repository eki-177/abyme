class ProjectsController < ApplicationController
  def index
  	@projects = Project.all
  	@project = Project.new
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
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

     if @project.update(project_params)
      redirect_to edit_project_path(@project)
    else
      render :edit
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to projects_path
  end

  private

  def project_params
  	params.require(:project).permit(
      :title, :description,
      tasks_attributes: [
        :id, 
        :title, 
        :description, 
        :_destroy, 
        comments_attributes: [
          :id, 
          :content, 
          :_destroy
        ]
      ],
      participants_attributes: [:id, :email, :_destroy]
    )
  end
end
