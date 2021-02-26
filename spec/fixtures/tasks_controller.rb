class TasksController < ApplicationController
  def index
    @tasks = Task.all
    @task = Task.new
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.save ? redirect_to(tasks_path) : render(:new)
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    @task.update(task_params)
    redirect_to edit_task_path(@task)
  end

  private

  def task_params
    params.require(:task).permit(:title, :description)
  end
end