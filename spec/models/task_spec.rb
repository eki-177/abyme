require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '::abyme_params' do
    it 'correctly builds a hash of authorized attributes for a single level of nesting' do
      comments_attributes = [:content, :id, :_destroy, :task_id]
      expect(Task.abyme_params).to include(:comments_attributes)
      expect(Task.abyme_params).not_to include(:tasks_attributes, :participants_attributes)
      expect(Task.abyme_params[:comments_attributes]).to match_array(comments_attributes)
    end
  end
end
