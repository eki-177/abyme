lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "abyme/version"

Gem::Specification.new do |spec|
  spec.name          = "abyme"
  spec.version       = Abyme::VERSION
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

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
