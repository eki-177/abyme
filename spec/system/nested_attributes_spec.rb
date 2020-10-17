require "rails_helper"
require_relative "../support/helpers/add_nested_attributes"

RSpec.describe "Nested attributes behaviour", type: :system do
  let(:description) { "La mise en abyme — également orthographiée mise en abysme ou plus rarement mise en abîme1 — est un procédé consistant à représenter une œuvre dans une œuvre similaire, par exemple dans les phénomènes de « film dans un film », ou encore en incrustant dans une image cette image elle-même (en réduction)." }
  context "Creating a brand new project" do
    it 'creates a project without any tasks' do
      visit new_project_path
      fill_in('project_title', with: "A project with no task")
      fill_in('project_description', with: description)    
      click_on('Save')
      expect(Project.last.title).to eq("A project with no task")
    end

    it "creates a project along with a few tasks", js: true do
      visit new_project_path
      fill_in('project_title', with: "A project with two tasks")
      fill_in('project_description', with: description)    
      add_tasks
      click_on('Save')
      expect(Project.last.title).to eq('A project with two tasks')
      expect(Project.last.tasks.count).to eq(2)
    end

    it "creates a project along with a few tasks, each with a few comments", js: true do
      visit new_project_path
      fill_in('project_title', with: "Another project with two tasks")
      fill_in('project_description', with: description)    
      add_tasks
      add_comments
      click_on('Save')
      expect(Project.last.comments.count).to eq(6)
    end

    it "creates a project along with participants, using the #abyme_for method without any block/option", js: true do
      visit new_project_path
      fill_in('project_title', with: "Another project with two tasks")
      fill_in('project_description', with: description)    
      add_participants
      click_on('Save')
      expect(Project.last.participants.count).to eq(2)
    end
  end

  context "Adding tasks to an existing project" do
    before(:example) do 
      @project = Project.create(title: "test", description: "La mise en abyme — également orthographiée mise en abysme ou plus rarement mise en abîme1 — est un procédé consistant à représenter une œuvre dans une œuvre similaire")
    end

    xit 'updates a project without any tasks', js: true do
      visit edit_project_path(@project)
      fill_in('project_title', with: "A rather small project")
      click_on('Save')
      @project.reload
      expect(@project.title).to eq('A rather small project')
    end

    it 'updates a project by adding a few tasks', js: true do
      visit edit_project_path(@project)
      add_tasks(3)
      add_comments(2)
      click_on('Save')
      @project.reload
      expect(@project.tasks.count).to eq(3)
      expect(@project.comments.count).to eq(9)
    end
  end

  context "Removing tasks from an existing project" do
    before(:context) do 
      @project = Project.create(title: "test", description: "La mise en abyme — également orthographiée mise en abysme ou plus rarement mise en abîme1 — est un procédé consistant à représenter une œuvre dans une œuvre similaire")
      3.times { |n| @project.tasks.create!(title: "task #{n}", description: "who cares") }
    end

    it 'updates a project by removing a task', js: true do
      visit edit_project_path(@project)
      find_all_by_id('i', "remove-task").last.click # Remove last task from page
      click_on('Save')
      @project.reload
      expect(@project.tasks.count).to eq(2)
      expect(@project.tasks.find_by(title: "task 3")).to be_nil
    end
  end
end