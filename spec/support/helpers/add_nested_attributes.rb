def add_tasks(number = 2)
  number.times { find_by_id("add-task").click }
  titles = find_all_by_id('input', /project_tasks_attributes_\d*_title/)
  descriptions = find_all_by_id('textarea', /project_tasks_attributes_\d*_description/ )
  titles.each_with_index {|title, n| title.fill_in(with: "Task #{n + 1}") }
  descriptions.each_with_index {|title, n| title.fill_in(with: "Small description for task number #{n + 1}") }
end

# def add_tasks_with_errors(number = 2)
#   number.times { find_by_id("add-task").click }
#   titles = find_all_by_id('input', /project_tasks_attributes_\d*_title/)
#   descriptions = find_all_by_id('textarea', /project_tasks_attributes_\d*_description/ )
#   descriptions.each_with_index {|title, n| title.fill_in(with: "Small description for task number #{n + 1}") }
# end

def add_comments(number = 2)
  add_comment_buttons = all('button', text: 'Add Comment')
  add_comment_buttons.each {|b| number.times { b.click } }
  comment_contents = find_all_by_id('input', /content/)
  comment_contents.each_with_index {|c, n| c.fill_in(with: "Comment ##{n}") }
end

def add_participants(number = 2)
  number.times { click_on('add participant') }
  within('div[data-association="participants"]') do
    emails = all("input")
    emails.each_with_index {|input, index| input.fill_in(with: "email_#{index}@gmail.com") }
  end
end

def find_all_by_id(element, matcher)
  all(element) {|el| el[:id].match? matcher }
end