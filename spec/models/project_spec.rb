require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '::abyme_params' do
    it 'correctly builds a hash of authorized attributes with several levels of nesting' do
      tasks_attributes = [:description, :title, :id, :_destroy]
      comments_attributes = [:content, :id, :_destroy, :task_id]
      # p "Task abyme params: #{Task.abyme_params}"
      project_attributes = Project.abyme_attributes
      expect(project_attributes).to include(:tasks_attributes, :participants_attributes)
      expect(project_attributes).not_to include(:comments_attributes)
      expect(project_attributes[:tasks_attributes]).to include(:description, :title, :id, :_destroy)
      expect(project_attributes[:tasks_attributes]).to include(a_kind_of(Hash))
      expect(project_attributes[:tasks_attributes].last[:comments_attributes]).to match_array(comments_attributes)
    end

    it "doesn't include _destroy attribute when passed an option to disallow destroy" do
      participants_attributes = [:email, :name, :id]
      project_attributes = Project.abyme_attributes
      expect(project_attributes[:participants_attributes]).to match_array(participants_attributes)
    end
  end
  
  describe "::abymize" do
    it "accepts both attributes and options" do
      # In Project.rb :
      # abymize :participants, permit: [:email, :name], allow_destroy: false
      participants_attributes = [:id, :email, :name]
      project_attributes = Project.abyme_attributes
      expect(project_attributes[:participants_attributes]).to match_array(participants_attributes)
      expect(Abyme::Model.instance_variable_get(:@allow_destroy).dig("Project", :participants)).to be_falsy
    end

    it "accepts only options without any attributes" do
      # In Project.rb :
      # abymize :meetings, allow_destroy: false
      project_attributes = Project.abyme_attributes
      expect(project_attributes[:meetings_attributes]).to be_nil
      expect(Abyme::Model.instance_variable_get(:@allow_destroy).dig("Project", :meetings)).to be_falsy
    end

    it "can be called without attributes nor any options" do
      # In Project.rb :
      # abymize :attachments
      project_attributes = Project.abyme_attributes
      expect(project_attributes[:attachments_attributes]).to be_nil
      expect(Abyme::Model.instance_variable_get(:@allow_destroy).dig("Project", :attachments)).to be_truthy
    end
  end
end
