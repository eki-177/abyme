# abyme 🕳

[![Gem Version](https://badge.fury.io/rb/abyme.svg)](https://badge.fury.io/rb/abyme)
![build](https://github.com/bear-in-mind/abyme/workflows/build/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/f591a9e00f7cf5188ad5/maintainability)](https://codeclimate.com/github/bear-in-mind/abyme/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/bear-in-mind/abyme/badge.svg?branch=master)](https://coveralls.io/github/bear-in-mind/abyme?branch=master)

abyme is an easy and form-agnostic way to handle nested attributes in Rails, using [stimulus](https://stimulusjs.org/handbook/introduction) under the hood. Here's an example :
```ruby
# views/projects/_form.html.erb
<%= form_for @project do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :description %>
  
  <%= f.abyme_for(:tasks) %>
  
  <%= f.submit 'Save' %>
<% end %>
```
Supposing you have a `Project` that `has_many :tasks` and a partial located in `views/abyme/_task_fields` containing your form fields for `tasks`, the `abyme_for` command will generate and display 3 elements in this order :
- A `div` containing all task fields for `@project.tasks` (either persisted or already built instances of `tasks`)
- A `div` which will contain all additional tasks about to be created (added through the `Add task` button below)
- A `button` to generate fields for new instances of tasks

Have a look below to learn more about configuration and all its different options.

## Demo app

![Demo preview](https://res.cloudinary.com/aux-belles-autos/image/upload/v1603040053/abyme-preview.gif)

Check out our demo app here : https://abyme-demo.herokuapp.com/

Source code is right here : https://github.com/bear-in-mind/abyme_demo

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'abyme'
```

And then execute:

    $ bundle
    $ yarn add abyme

***IMPORTANT : With the launch of Stimulus V3 (which introduced a lot of changes), the connection with the AbymeController won't work. Please, make sure you're using Stimulus V2 for now.***

If you don't have Stimulus installed yet, please run :
```bash
yarn add stimulus@2.0.0
```

With [Stimulus](https://stimulusjs.org/handbook/introduction) installed, you need to register the `stimulus` controller that takes care of the JavaScript behaviour. You can launch this generator :
```bash
rails generate abyme:stimulus
```
Or you can register it yourself :

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

## Getting started

To learn more about the *why* of this gem, check out our [wiki](https://github.com/bear-in-mind/abyme/wiki/What-are-nested-forms-and-why-a-new-gem-%3F)

You may also check out our [step by step tutorial](https://github.com/bear-in-mind/abyme/wiki/Step-by-step-Tutorial) and our [advanced configuration guide](https://github.com/bear-in-mind/abyme/wiki/Step-by-step-:-Advanced-configuration) (currently in construction).
## Documentation
As in our [our tutorial](https://github.com/bear-in-mind/abyme/wiki/Step-by-step-Tutorial), we'll assume we have a `Project` model, that `has_many :tasks` for the rest of the documentation.
### Generators
To be up and running in no time, we built a few generators. Feel free to skip these if you prefer a manual implementation.
#### Resource
To generate everything you need with one command, use this generator :
```bash
rails generate abyme:resource project tasks
# Includes configuration in Project model
# Adds abyme_attributes in ProjectsController permitted params
# Creates a partial and minimum boilerplate in app/views/abyme/_task_fields.html.erb
```
Now, head to your parent form and [keep reading](https://github.com/eki-177/abyme#abyme_forassociation-options---block) !

You can also specify [attributes to be permitted](https://github.com/eki-177/abyme#model), or permit all of them (see below). This will populate the partial with input fields for the specified attributes
```bash
rails generate abyme:resource project tasks description title
# Includes configuration in Project model, including permitted attributes
# Adds abyme_attributes in ProjectsController permitted params
# Creates a partial with input fields for the specified attributes in app/views/abyme/_task_fields.html.erb
```

#### Individual generators
All the generators launched by the main `resource` generator are available individually :
```bash
# Controller
rails generate abyme:controller Projects

# Model
# Permit only a few attributes
rails generate abyme:model project tasks description title
# Permit all attributes
rails generate abyme:model project participants all_attributes

# Views
# Without attributes (use this if you're not using SimpleForm or don't care about generating input fields)
rails generate abyme:view tasks
# With a few attributes
rails generate abyme:view tasks name description
# With all attributes
rails generate abyme:view tasks all_attributes
```

### Model

💡 Don't forget to `include Abyme::Model` in your parent model

#### #abymize(:association, permit: nil, reject: nil, options = {})
In models, the `abyme_for :association` acts as an alias for this command :
```ruby
  accepts_nested_attributes_for :association, reject_if: :all_blank, :allow_destroy: true
```

* `permit: []` : allows you to generate a hash of attributes that can be easily called on the controller side through the `::abyme_attributes` class method (see details below).
```ruby
  abymize :association, permit: [:name, :description]
  
  # You may also permit all attributes like so :
  abymize :association, permit: :all_attributes 
```

* `reject: []` : allows you to add all attributes to `::abyme_attributes`, excepted the ones specified.
```ruby
  abymize :association, reject: [:password]
```

* `options: {}` : [the same options] you may pass to the `accepts_nested_attributes` method (see [this link](https://api.rubyonrails.org/v6.1.0/classes/ActiveRecord/NestedAttributes/ClassMethods.html) for details)
```ruby
  abyme_for :association, limit: 3, allow_destroy: false
```

#### ::abyme_attributes
Returns a hash to the right format to be included in the `strong params` on the controller side. For a `Project` model with nested `:tasks` :
```ruby
  Project.abyme_attributes
  # => {tasks_attributes: [:title, :description, :id, :_destroy]}
```

### Controller
#### #abyme_attributes
Infers the name of the resource from the controller name, and calls the `::abyme_attributes` method on it. Hence, in your `ProjectsController` :
```ruby
  def project_params
    params.require(:project).permit(:title, :description, abyme_attributes)
  end
```

### Views

#### #abyme_for(:association, options = {}, &block)
This is the container for all your nested fields. It takes the symbolized association as a parameter, along with options, and an optional block to specify any layout you may wish for the different parts of the `abyme` builder. 

💡 Please note an id is automatically added to this element, which value is : `abyme--association_name`.

💡  If you don't pass a block, `records`, `new_records` and `add_association` will be called and will appear in this order in your layout.
* `partial: ` : allows you to indicate a custom partial path for both `records` and `new_records`
```ruby
  <%= f.abyme_for(:tasks, partial: 'projects/task_fields') do |abyme| %>
    <%= abyme.records %>
    <%= abyme.new_records %>
    <%= add_associated_record %>
  <% end %>
```
* `limit: ` : allows you to limit the number of new fields that can be created through JS. If you need to limit the number of associations in database, you will need to add validations. You can also pass an option [in your model as well](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for).
```ruby
  <%= f.abyme_for(:tasks, limit: 5) do |abyme| %>
    # Beyond 5 tasks, the add button won't add any more fields. See events section below to see how to handle the 'abyme:limit-reached' event
    <%= abyme.records %>
    <%= abyme.new_records %>
    <%= add_associated_record %>
  <% end %>
```
* `min_count: ` : by default, there won't be any blank fields added on page load. By passing a `min_count` option, you can set how many empty fields should appear in the form.
```ruby
  <%= f.abyme_for(:tasks, min_count: 1) do |abyme| %>
    # 1 blank task will automatically be added to the form.
    <%= abyme.records %>
    <%= abyme.new_records %>
    <%= add_associated_record %>
  <% end %>
```

* `locals: {}` : allows you to pass some arbitrary variables to your partial.
```ruby
<%= f.abyme_for(:comments, locals: {count: 0}) %>
```
The `count` variable will be available in `_comment_fields.html.erb` and equal 0 for both new and persisted records.

*If you're not passing a block*, the `abyme_for` method can take a few additional options:
* `button_text: ` this will set the `add_association` button text to the string of your choice.

💡 All options that should be passed to either `records` or `new_records` below can be passed here and will be passed down.

#### #records
A few options can be passed to `abyme.records`:
* `collection:` : allows you to pass a collection of your choice to only display specific objects.
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    <%= abyme.records(collection: @project.tasks.where(done: false)) %>
    <%= abyme.new_records %>
    <%= add_associated_record %>
  <% end %>
```
* `order:` : allows you to pass an ActiveRecord `order` method to sort your instances the way you want.
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    <%= abyme.records(order: { created_at: :asc }) %>
    <%= abyme.new_records %>
    <%= add_associated_record %>
  <% end %>
```
* `partial:` : allows you to indicate a custom partial, if one has not already been passed to `abyme_for`.
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    <%= abyme.records %>
    <%= abyme.new_records(partial: 'projects/task_fields') %>
    <%= add_associated_record %>
  <% end %>
```
* `fields_html:` : gives you the possibility to add any HTML attribute you may want to each set of fields. By default, an `abyme--fields` and an `singular_association-fields` class are already present.
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    <%= abyme.records(fields_html: { class: "some-class" }) %>
    # Every set of persisted fields will have these 3 classes : 'abyme--fields', 'task-fields', and 'some-class'
    <%= abyme.new_records %>
    <%= add_associated_record %>
  <% end %>
```
* `wrapper_html:` : gives you the possibility to add any HTML attribute you may want to the wrapper containing all persisted fields.
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    <%= abyme.records(wrapper_html: { class: "persisted-records" }) %>
    # The wrapper containing all persisted task fields will have an id "abyme-tasks-wrapper" and a class "persisted-records"
    <%= abyme.new_records %>
    <%= add_associated_record %>
  <% end %>
```
* `locals: {}` : allows you to pass some arbitrary variables to your partial. When passed to either #records or #new_records, the value will be different depending on whether the record for which the partial is called is persisted or not
```ruby
<%= f.abyme_for(:tasks) do |abyme| %>
  <%= abyme.records(locals: {count: 1}) %>
  <%= abyme.new_records(locals: {count: 2} %>
  <%= add_associated_record(content: 'Add task' %>
<% end %>
```

In `_task_fields.html.erb`, if the record has been dynamically added with the "Add" button, the `count`variable will be equal to 2. 
If the record has been loaded from existing associations, it will equal 1.

#### #new_records
Here are the options that can be passed to `abyme.new_records`:
* `position:` : allows you to specify whether new fields added dynamically should go at the top or at the bottom. `:end` is the default value.
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    <%= abyme.records %>
    <%= abyme.new_records(position: :start) %>
    <%= add_associated_record %>
  <% end %>
```
* `partial:` : same as `#records`
* `fields_html:` : same as `#records`
* `wrapper_html:` : same as `#records`
* * `locals:` : same as `#records`

#### #add_associated_record, #remove_associated_record
These 2 methods behave the same. Here are their options :
* `tag:` : allows you to specify a tag of your choosing, like `:a`, or `:div`. Default is `:button`.
* `content:` : the text to display inside the element. Default is `Add association_name`
* `html:` : gives you the possibility to add any HTML attribute you may want to the element.
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    # ...
    <%= add_associated_record(tag: :a, content: "Add a super task", html: {id: "add-super-task"}) %>
  <% end %>
```

As you may have seen above, you can also pass a block to the method to give it whatever HTML content you want :
```ruby
  <%= f.abyme_for(:tasks) do |abyme| %>
    # ...
    <%= add_associated_record(tag: :div, html: {id: "add-super-task", class: "flex"}) do %>
      <i class="fas fa-plus"></i>
      <h2>Add a super task</h2>
    <% end %>
  <% end %>
```

## Events
This part is still a work in progress and subject to change. We're providing some basic self-explanatory events to attach to. These are emitted by the main container (created by the `abyme_for` method).

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

Bug reports and pull requests are welcome on GitHub at https://github.com/eki-177/abyme.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
