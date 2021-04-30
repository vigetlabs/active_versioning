# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'active_versioning/version'

Gem::Specification.new do |spec|
  spec.name          = "active_versioning"
  spec.version       = ActiveVersioning::VERSION
  spec.authors       = ["Ryan Stenberg"]
  spec.email         = ["ryan.stenberg@viget.com"]

  spec.summary       = "Plug-and-Play Versioning for Rails"
  spec.description   = "ActiveVersioning serializes attributes when records are saved and allows for version and draft management."
  spec.homepage      = "https://github.com/vigetlabs/active_versioning"
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 5.0"

  spec.add_development_dependency "bundler", ">= 1.10"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "shoulda-matchers", '2.8.0'
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "generator_spec"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "sqlite3"
end
