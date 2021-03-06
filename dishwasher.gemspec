lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dishwasher/version"

Gem::Specification.new do |spec|
  spec.name = "dishwasher"
  spec.version = Dishwasher::VERSION
  spec.authors = ["Andrew Mason"]
  spec.email = ["andrewmcodes@protonmail.com"]

  spec.summary = "Clean up your GitHub forks"
  spec.description = "A CLI tool written in Ruby to help you remove unneeded GitHub forks."
  spec.homepage = "https://github.com/andrewmcodes/dishwasher"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/andrewmcodes/dishwasher"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "artii"
  spec.add_dependency "octokit", "~> 4.0"
  spec.add_dependency "tty-prompt", "~> 0.19"

  # Development Dependencies
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "standard"
end
