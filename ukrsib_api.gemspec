# frozen_string_literal: true

require_relative "lib/ukrsib_api/version"

Gem::Specification.new do |spec|
  spec.name = "ukrsib_api"
  spec.version = UkrsibAPI::VERSION
  spec.authors = ["merof"]
  spec.email = ["misha.rosh@gmail.com"]

  spec.summary = "api wrapper for ukrsib bank api"
  spec.description = "Unofficial Ruby Gem for ukrsib bank business API."
  spec.homepage = "https://github.com/merof-code/ukrsib_api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/merof-code/ukrsib_api/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "base64"
  spec.add_dependency "dry-struct", "~> 1.7"
  spec.add_dependency "dry-transformer", "~> 1"
  spec.add_dependency "dry-types", "~> 1.7"
  spec.add_dependency "faraday", "~> 1.7"
  spec.add_dependency "faraday_middleware", "~> 1.1"
  spec.add_dependency "money", "~> 6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
