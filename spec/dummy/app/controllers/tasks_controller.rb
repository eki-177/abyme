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

  private

  def task_params
    params.require(:task).permit(abyme_attributes, :title, :description)
  end
end
