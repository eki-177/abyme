lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "abyme/version"

Gem::Specification.new do |spec|
  spec.name          = "abyme"
  spec.version       = Abyme::VERSION::STRING
  spec.authors       = ["Romain Sanson", "Louis Sommer"]
  spec.email         = ["louis.sommer@hey.com"]

  spec.summary       = "abyme is the modern way to handle dynamic nested forms in Rails 6+."
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/bear-in-mind/abyme"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bear-in-mind/abyme"
  spec.metadata["changelog_uri"] = "https://github.com/bear-in-mind/abyme"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # SimpleForm dependency is only required for test purposes and optional behaviour
  spec.add_development_dependency 'simple_form'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  # Tests
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency 'rails-controller-testing'
  spec.add_development_dependency 'database_cleaner-active_record'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'webdrivers'
  spec.add_development_dependency "generator_spec"
  
  # Dummy app
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'rails', "~> 6.0.3.6"
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'web-console'

  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-lcov'
end
