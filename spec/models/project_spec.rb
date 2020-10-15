require 'rails_helper'

RSpec.describe Project, type: :model do
  it 'has a valid factory' do
    project = build(:project)
    expect(project).to be_valid
  end
end
