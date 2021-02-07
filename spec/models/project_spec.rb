require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '::abyme_params' do
    it 'correctly builds a hash of authorized attributes' do
      tasks_attributes = [
        :description, :title, :id, :_destroy, comments_attributes: [
          :content, :id, :_destroy, :task_id
        ]
      ]
      participants_attributes = [:email, :name, :id, :_destroy]
      # p "Task abyme params: #{Task.abyme_params}"
      # p "Project abyme params: #{Project.abyme_params}"
      expect(Project.abyme_params).to include(:tasks_attributes, :participants_attributes)
      expect(Project.abyme_params).not_to include(:comments_attributes)
      expect(Project.abyme_params[:tasks_attributes]).to match_array(tasks_attributes)
      expect(Project.abyme_params[:participants_attributes]).to match_array(particpants_attributes)
    end
  end
end
