require "rails_helper"
require_relative "../support/helpers/add_nested_attributes"

RSpec.describe "Nested attributes behaviour", type: :system do
  before do
    driven_by :selenium_chrome_headless
  end

  let(:description) { "La mise en abyme — également orthographiée mise en abysme ou plus rarement mise en abîme1 — est un procédé consistant à représenter une œuvre dans une œuvre similaire, par exemple dans les phénomènes de « film dans un film », ou encore en incrustant dans une image cette image elle-même (en réduction)." }
  context "Creating a brand new project" do
    it "creates a project without any tasks" do
      visit new_project_path
      fill_in("project_title", with: "A project with no task")
      fill_in("project_description", with: description)
      click_on("Save")
      expect(Project.last.title).to eq("A project with no task")
    end

    it "creates a project along with a few tasks" do
      visit new_project_path
      fill_in("project_title", with: "A project with two tasks")
      fill_in("project_description", with: description)
      add_tasks
      click_on("Save")
      expect(Project.last.title).to eq("A project with two tasks")
      expect(Project.last.tasks.count).to eq(2)
    end

    it "creates a project along with a few tasks, each with a few comments" do
      visit new_project_path
      fill_in("project_title", with: "Another project with two tasks")
      fill_in("project_description", with: description)
      add_tasks
      add_comments
      click_on("Save")
      expect(Project.last.comments.count).to eq(2)
    end

    it "creates a project along with participants, using the #abyme_for method without any block/option" do
      visit new_project_path
      fill_in("project_title", with: "Another project with two tasks")
      fill_in("project_description", with: description)
      add_participants
      click_on("Save")
      expect(Project.last.participants.count).to eq(2)
    end
  end

  context "Adding tasks to an existing project" do
    before(:all) do
      @project_with_no_task = Project.create(title: "test", description: "La mise en abyme — également orthographiée mise en abysme ou plus rarement mise en abîme1 — est un procédé consistant à représenter une œuvre dans une œuvre similaire")
    end

    it "updates a project by adding a few tasks" do
      visit edit_project_path(@project_with_no_task)
      add_tasks(3)
      add_comments(2)
      click_on("Save")
      @project_with_no_task.reload
      expect(@project_with_no_task.tasks.count).to eq(3)
      # expect(@project_with_no_task.comments.count).to eq(9)
    end
  end

  context "Removing tasks from an existing project" do
    before(:all) do
      @project_with_tasks = Project.create(title: "test", description: "La mise en abyme — également orthographiée mise en abysme ou plus rarement mise en abîme1 — est un procédé consistant à représenter une œuvre dans une œuvre similaire")
      3.times { |n| @project_with_tasks.tasks.create!(title: "task #{n}", description: "who cares") }
    end

    it "updates a project by removing a task" do
      visit edit_project_path(@project_with_tasks)
      find_all_by_id("p", "remove-task").last.click # Remove last task from page
      click_on("Save")
      @project_with_tasks.reload
      expect(@project_with_tasks.tasks.count).to eq(2)
      expect(@project_with_tasks.tasks.find_by(title: "task 3")).to be_nil
    end
  end
end
