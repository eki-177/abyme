# Abyme 🕳

abyme is a modern take on handling dynamic nested forms in Rails 6+ using StimulusJS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'abyme'
```

And then execute:

    $ bundle
    $ yarn add 'abyme'


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

Nested forms (or more accurately *nested fields* or *nested attributes*) are forms that deal with associated models. Let's picture a `Project` model that `has_many :tasks` ; a nested form will allow you to create a project along with one or several tasks **within a single form**. If `Tasks` were to have associations on their own, like `:comments`, you could also, still in the same form, instantiate comments along with their parent models.

Rails provides [its own helper](https://api.rubyonrails.org/v6.0.1/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for) to handle nested attributes. **abyme** is basically a smart wrapper around it, offering easier syntax along with some fancy additions. To work properly, some configuration will be required in both models and controllers (see below).

What Rails doesn't provide natively is the possibility to dynamically add new associations on the fly, which requires Javascript implementation. What this means it that you would normally have to know in advance how many fields you'd like to display (1, 2 or any number of `:tasks`), which isn't very usable in this day and age. This is what the [cocoon gem](https://github.com/nathanvda/cocoon) has been helping with for the past 7 years. This gem still being implemented in JQuery (which [Rails dropped as a dependency](https://github.com/rails/rails/issues/25208)), we wanted to propose a more plug'n'play approach, using Basecamp's [Stimulus](https://stimulusjs.org/) instead.

## Usage



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/abyme.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
