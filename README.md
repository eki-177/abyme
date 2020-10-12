# Abyme

abyme is a modern take on handling dynamic nested forms in Rails 6+, using StimulusJS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'abyme'
```

And then execute:

    $ bundle
    $ yarn add 'abyme'


Or install it yourself as:

    $ gem install abyme

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

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/abyme.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
