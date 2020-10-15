# Abyme 🕳

abyme is a modern take on handling dynamic nested forms in Rails 6+ using StimulusJS.

## Disclaimer
This project is still a work in progress and subject to change. We encourage not to use it in production code just yet.

Any enhancement proposition or bug report welcome !

General remarks : 
* A demo app will soon be online.
* For now, the gem is tested through our demo app. Specific autonomous tests will be transfered/written in the following days.
* Help is very much wanted on the Events part of the gem (see bottom of this documentation)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'abyme'
```

And then execute:

    $ bundle
    $ yarn add abyme


Assuming you [already installed Stimulus](https://stimulusjs.org/handbook/introduction), add this in `app/javascript/controllers/index.js` :
```javascript
// app/javascript/controllers/index.js
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
// Add this line below
import { AbymeController } from 'abyme'

const application = Application.start()
const context = require.context("controllers", true, /_controller\.js$/)
application.load(definitionsFromContext(context))
// And this one
application.register('abyme', AbymeController)
```

## What are nested forms and why a new gem ?

Nested forms (or more accurately *nested fields* or *nested attributes*) are forms that deal with associated models. Let's picture a `Project` model that `has_many :tasks`. A nested form will allow you to create a project along with one or several tasks **within a single form**. If `Tasks` were to have associations on their own, like `:comments`, you could also, still in the same form, instantiate comments along with their parent models.

Rails provides [its own helper](https://api.rubyonrails.org/v6.0.1/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for) to handle nested attributes. **abyme** is basically a smart wrapper around it, offering easier syntax along with some fancy additions. To work properly, some configuration will be required in both models and controllers (see below).

What Rails doesn't provide natively is the possibility to **dynamically add new associations on the fly**, which requires Javascript implementation. What this means it that you would normally have to know in advance how many fields you'd like to display (1, 2 or any number of `:tasks`), which isn't very usable in this day and age. This is what the [cocoon gem](https://github.com/nathanvda/cocoon) has been helping with for the past 7 years. This gem still being implemented in JQuery (which [Rails dropped as a dependency](https://github.com/rails/rails/issues/25208)), we wanted to propose a more plug'n'play approach, using Basecamp's [Stimulus](https://stimulusjs.org/) instead.

## Basic Configuration

### Models
Let's consider a to-do application with Projects having many Taks, themselves having many Comments.
```ruby
# models/project.rb
class Project < ApplicationRecord
  has_many :tasks
  validates :title, :description, presence: true
end

# models/task.rb
class Task < ApplicationRecord
  belongs_to :project
  has_many :comments
  validates :title, :description, presence: true
end

# models/comment.rb
class Comment < ApplicationRecord
  belongs_to :task
  validates :content, presence: true
end
```
The end-goal here is to be able to create a project along with different tasks, and immediately add comments to some of these tasks ; all within a single form.
What we'll have is a 2-level nested form. Thus, we'll need to configure our `Project` and `Task` models like so :
```ruby
# models/project.rb
class Project < ApplicationRecord
  include Abyme::Model
  has_many :tasks, inverse_of: :project
  # ...
  abyme_for :tasks
end

# models/task.rb
class Task < ApplicationRecord
  include Abyme::Model
  has_many :comments, inverse_of: :task
  # ...
  abyme_for :comments
end
```
Note the use of the `inverse_of` option. It is needed for Rails to effectively associate children to their yet unsaved parent. Have a peek to the bottom of [this page](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for) for more info.

### Controller
Since we're dealing with one form, we're only concerned with one controller : the one the form routes to. In our example, this would be the `ProjectsController`.
The only configuration needed here will concern our strong params. Nested attributes require a very specific syntax to white-list the permitted attributes. It looks like this :

```ruby
def project_params
  params.require(:project).permit(
    :title, :description, tasks_attributes: [
      :id, :title, :description, :_destroy, comments_attributes: [
        :id, :content, :_destroy
      ]
    ]
  )
end
```
A few explanations here. 

* To permit a nested model attributes in your params, you'll need to pass the `association_attributes: [...]` hash at the end of your resource attributes. Key will always be `association_name` followed by `_attributes`, while the value will be an array of symbolized attributes, just like usual.

> **Note**: if your association is a singular one (`has_one` or `belongs_to`) the association will be singular ; if a Project `has_one :owner`, you would then need to pass `owner_attributes: [...]`)

* You may have remarked the presence of `id` and `_destroy` among those params. These are necessary for edit actions : if you want to allow your users to destroy or update existing records, these are **mandatory**.  Otherwise, Rails won't be able to recognize these records as existing ones, and will just create new ones. More info [here](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html).

## Basic Usage

Dealing with nested attributes means you'll generally have to handle a few things inside your form:
* Display fields for the **persisted records** (here, already existing `:tasks`)
* Display fields for the **new records** (future `:tasks` not yet persisted)
* A button to **trigger the addition** of fields for a new resource (an `Add a new task` button)
* A button to **remove fields** for a given resource (`Remove task`)

abyme provides helper methods for all these. Here's how our form for `Project` looks like when using default values:

```ruby
# views/projects/_form.html.erb
<%= simple_form_for @project do |f| %>
  <%= f.input :title %>
  <%= f.input :description %>
  <%= f.submit 'Save' %>

  <%= abymize(:tasks, f) do |abyme| %>
    <%= abyme.records %>
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
<% end %>
```

`abyme.records` will contain the persisted associations fields, while `abyme.new_records` will contain fields for the new associations. `add_association` will by default generate a button with a text of type "Add `resource_name`". To work properly, this method **has** to be called **inside the block** passed to the `abymize` method.

Now where's the code for these fields ? abyme will assume a **partial** to be present in the directory `/views/abyme` with a *name respecting this naming convention* (just like with [cocoon](https://github.com/nathanvda/cocoon#basic-usage)): `_singular_association_name_fields.html.erb`. 

This partial might look like this:
```ruby
# views/abyme/_task_fields.html.erb
<%= f.input :title %>
<%= f.input :description %>
<%= f.hidden_field :_destroy %>

<%= remove_association(tag: :div) do %>
  <i class="fas fa-trash"></i>
<% end %>
```

Note the presence of the `remove_association` button. Here, we pass it an option to make it a `<div>`, as well as a block to customize its content. Don't forget the `_destroy` attribute, needed to mark items for destruction.

### What about the controller ?

What about it ? Well, not much. That's the actual magical thing about `nested_attributes`: once your model is aware of its acceptance of those for a given association, and your strong params are correctly configured, there's nothing else to do.
`@project.create(project_params)` is all you'll need to save a project along with its descendants 👨‍👧‍👧

### Auto mode

Let's now take care of our comments fields. We'll add these using our neat *automatic mode*: just stick this line at the end of the partial:
```ruby
# views/abyme/_task_fields.html.erb
# ... rest of the partial above
<%= abymize(:comments, f) %>
```
Where's the rest of the code ? Well, if the default configuration you saw above in the `_form.html.erb` suits you, and the order in which the different resources appear feels right (persisted first, new fields second, and the 'Add' button last), then you can just spare the block, and it will be taken care of for you. We'll just write our `_comment_fields.html.erb` partial in the `views/abyme` directory and we'll be all set.

## Advanced usage
### Models
In models, the `abyme_for :association` acts as an alias for this command :

```ruby
  accepts_nested_attributes_for :association, reject_if: :all_blank, :allow_destroy: true
```

Which is the way you would configure `nested_attributes` 90% of the time. Should you want to pass [any available options](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for) to this method or change those, you may just pass them as with the original method :
```ruby
  abyme_for :association, limit: 3, allow_destroy: false
```

### Views

#### #records
A few options can be passed to `abyme.records`:
* `collection:` : allows you to pass a collection of your choice to only display specific objects.
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    <%= abyme.records(collection: @project.tasks.where(done: false)) %>
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
```
* `order:` : allows you to pass an ActiveRecord `order` method to sort your instances the way you want.
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    <%= abyme.records(order: { created_at: :asc }) %>
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
```
* `partial:` : allows you to indicate a custom partial, if one has not already been passed to `abymize`.
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    <%= abyme.records %>
    <%= abyme.new_records(partial: 'projects/task_fields') %>
    <%= add_association %>
  <% end %>
```
* `fields_html:` : gives you the possibility to add any HTML attribute you may want to each set of fields. By default, an `abyme--fields` and an `singular_association-fields` class are already present.
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    <%= abyme.records(fields_html: { class: "some-class" }) %>
    # Every set of persisted fields will have these 3 classes : 'abyme--fields', 'task-fields', and 'some-class'
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
```
* `wrapper_html:` : gives you the possibility to add any HTML attribute you may want to the wrapper containing all fields.
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    <%= abyme.records(wrapper_html: { class: "persisted-records" }) %>
    # The wrapper containing all persisted task fields will have an id "abyme-tasks-wrapper" and a class "persisted-records"
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
```
#### #new_records
Here are the options that can be passed to `abyme.new_records`:
* `position:` : allows you to specify whether new fields added dynamically should go at the top or at the bottom. `:end` is the default value.
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    <%= abyme.records %>
    <%= abyme.new_records(position: :start) %>
    <%= add_association %>
  <% end %>
```
* `partial:` : same as `#records`
* `fields_html:` : same as `#records`
* `wrapper_html:` : same as `#records`

#### #add_association, #remove_association
These 2 methods behave the same. Here are their options :
* `tag:` : allows you to specify a tag of your choosing, like `:a`, or `:div`. Default is `:button`.
* `content:` : the text to display inside the element. Default is `Add association_name`
* `html:` : gives you the possibility to add any HTML attribute you may want to the element.
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    # ...
    <%= add_association(tag: :a, content: "Add a super task", html: {id: "add-super-task"}) %>
  <% end %>
```

As you may have seen above, you can also pass a block to the method to give it whatever HTML content you want :
```ruby
  <%= abymize(:tasks, f) do |abyme| %>
    # ...
    <%= add_association(tag: :div, html: {id: "add-super-task", class: "flex"}) do %>
      <i class="fas fa-plus"></i>
      <h2>Add a super task</h2>
    <% end %>
  <% end %>
```


#### #abymize(:association, form_object)
This is the container for all your nested fields. It takes two parameters (the symbolized association and the `form_builder`), and some optional ones. Please note an id is automatically added to this element, which value is : `abyme--association`. 
* `partial:` : allows you to indicate a custom partial path for both `records` and `new_records`
```ruby
  <%= abymize(:tasks, f, partial: 'projects/task_fields') do |abyme| %>
    <%= abyme.records %>
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
```
* `limit:` : allows you to limit the number of new fields that can be created through JS. If you need to limit the number of associations in database, you will need to add validations. You can also pass an option [in your model as well](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for).
```ruby
  <%= abymize(:tasks, f, limit: 5) do |abyme| %>
    # Beyond 5 tasks, the add button won't add any more fields. See events section below to see how to handle the 'abyme:limit-reached' event
    <%= abyme.records %>
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
```
* `min_count` : by default, there won't be any blank fields added on page load. By passing a `min_count` option, you can set how many empty fields should appear in the form.
```ruby
  <%= abymize(:tasks, f, min_count: 1) do |abyme| %>
    # 1 blank task will automatically be added to the form.
    <%= abyme.records %>
    <%= abyme.new_records %>
    <%= add_association %>
  <% end %>
```

*When in auto mode*, the abymize method can take a few options:
* `button_text:` : this will set the `add_association` button text to the string of your choice.
* All options that should be passed to either `records` or `new_records` can be passed here and will be passed down.

## Events
This part is still a work in progress and subject to change. We're providing some basic self-explanatory events to attach to. These are emitted by the main container (created by the `abymize` method).

We're currently thinking about a way to attach to these via Stimulus. Coming soon !

### Lifecycle events
* `abyme:before-add`
* `abyme:after-add`
* `abyme:before-remove`
* `abyme:after-remove`
```javascript
document.getElementById('abyme--tasks').addEventListener('abyme:before-add', yourCallback)
```

### Other events
* `abyme:limit-reached`
```javascript
const tasksContainer = document.getElementById('abyme--tasks');
tasksContainer.addEventListener('abyme:limit-reached', () => { 
  alert('You reached the max number of tasks !')
});
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bear-in-mind/abyme.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
