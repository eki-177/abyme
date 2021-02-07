require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '::abyme_params' do
    it 'correctly builds a hash of authorized attributes for several levels of nesting' do
      tasks_attributes = [:description, :title, :id, :_destroy]
      comments_attributes = [:content, :id, :_destroy, :task_id]
      participants_attributes = [:email, :name, :id, :_destroy]
      # p "Task abyme params: #{Task.abyme_params}"
      project_attributes = Project.abyme_params
      expect(project_attributes).to include(:tasks_attributes, :participants_attributes)
      expect(project_attributes).not_to include(:comments_attributes)
      expect(project_attributes[:tasks_attributes]).to include(:description, :title, :id, :_destroy)
      expect(project_attributes[:tasks_attributes]).to include(a_kind_of(Hash))
      expect(project_attributes[:tasks_attributes].last[:comments_attributes]).to match_array(comments_attributes)
      expect(project_attributes[:participants_attributes]).to match_array(participants_attributes)
    end
  end
end
