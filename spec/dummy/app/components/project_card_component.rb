class ProjectCardComponent < ViewComponent::Base
	attr_reader :project
	with_collection_parameter :project

  def initialize(project:)
    @project = project
  end

  def title
  	project.title
  end

  def description
  	project.description.truncate(500)
  end

  def created_at
  	project.created_at.strftime('%A, %b %d')
  end
end
