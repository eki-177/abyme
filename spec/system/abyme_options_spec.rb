require "rails_helper"
require_relative "../support/helpers/add_nested_attributes"

RSpec.describe "Helper options", type: :system do
  before(:each) do
    Capybara.current_driver = :selenium_headless
  end

  context 'For new resources' do
    describe "Partials default & custom path" do
      it 'should set the correct partial when path specified' do
        visit new_project_path
        add_tasks(1)
        element = find('.custom-partial')
        expect(element).not_to be_nil
      end
    
      it 'should set the correct partial when path not specified' do
        visit new_project_path
        click_on('add participant')
        within('#abyme--participants') do
          expect(".abyme--fields").not_to be_nil
        end
      end
    end
    
    # describe "Render error feedback", type: :system do
    #   it 'should render error feedback for main resource' do
    #     visit new_project_path
    #     fill_in('project_description', with: 'A project description')
    #     click_on('Save')
    #     save_and_open_page
    #     element = find('.error')
    #     expect(element).not_to be_nil
    #   end
    
    #   it 'should render error feedback for nested resources' do
    #     visit new_project_path
    #     fill_in('project_title', with: "A project with two tasks")
    #     fill_in('project_description', with: 'A project description')
    #     add_tasks(1)
    #     add_tasks_with_errors(1)
    #     click_on('Save')
    #     save_and_open_page
    #     element = find('.error')
    #     expect(element).not_to be_nil
    #   end
    # end
  
    describe "HTML attributes for 'abyme-fields' & add/remove association" do
      it 'should create the correct id' do
        visit new_project_path
        element = find('#add-task')
        expect(element).not_to be_nil
      end
    
      it 'should create the correct classes' do 
        visit new_project_path
        click_on('add participant')
        element = find('.participant-fields')
        expect(element).not_to be_nil
      end
    
      it 'should add the base classes "abyme--fields" and "association-fields' do
        visit new_project_path
        click_on('add participant')
        element = find('.abyme--fields.participant-fields')
        expect(element).not_to be_nil
      end
  
      it 'should allow HTML to be passed to the wrapper' do
        visit new_project_path
        click_on('Add task')
        expect(find('.new-tasks')).not_to be_nil
      end
  
      it 'should allow HTML to be passed to each field' do
        visit new_project_path
        2.times { click_on('Add task') }
        expect(find_all('.test').length).to eq(2)
      end
  
      it 'should allow data-attributes to be passed to the wrapper' do
        visit new_project_path
        click_on('Add task')
        expect(find('.new-tasks[data-controller="tasks-wrapper"]')).not_to be_nil
      end
  
      it 'should allow data-attributes to be passed to the fields without overwriting the defaults' do
        visit new_project_path
        click_on('Add task')
        expect(find('.test[data-target="abyme.fields abyme.newFields sub-target"]')).not_to be_nil
      end
    
      it 'should set the correct inner text for the add association button' do
        visit new_project_path
        element = find('button', text: 'add participant')
        expect(element).not_to be_nil
      end
  
      it 'should not create more than 3 tasks' do
        visit new_project_path
        4.times { click_on('Add task') }
        task_fields = []
        within('#abyme--tasks') { expect(all('.task-fields').length).to eq(3) }
      end
      
      it 'should display 1 default empty comment per task' do
        visit new_project_path
        click_on('Add task')
        within('#abyme--comments') do
          expect(find('.comment-fields')).not_to be_nil
        end 
      end
    end
  end

  context "With existing tasks" do
    before(:all) do
      @project = Project.create(title: "test", description: "La mise en abyme — également orthographiée mise en abysme ou plus rarement mise en abîme1 — est un procédé consistant à représenter une œuvre dans une œuvre similaire")
      3.times { |n| @project.tasks.create!(title: "task #{n}", description: "who cares") }
    end

    it 'should add the base classes "abyme--fields" and "association-fields' do
      visit edit_project_path(@project)
      elements = find_all('.abyme--fields.task-fields')
      expect(elements).not_to be_empty
    end

    it 'should allow HTML to be passed to the wrapper' do
      visit edit_project_path(@project)
      expect(find('.persisted-tasks')).not_to be_nil
    end

    it 'should allow HTML to be passed to each field withot overwriting defaults' do
      visit edit_project_path(@project)
      expect(find_all('.abyme--fields.task-fields.persisted-fields')).not_to be_empty
    end

    it 'should allow data-attributes to be passed to the wrapper' do
      visit edit_project_path(@project)
      expect(find('.persisted-tasks[data-controller="tasks-wrapper"]')).not_to be_nil
    end

    it 'should allow data-attributes to be passed to the fields without overwriting the defaults' do
      visit edit_project_path(@project)
      expect(find('.persisted-fields[data-target="abyme.fields tasks-wrapper.test"]')).not_to be_nil
    end
  end
end