# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/document_requests/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-document_requests"
  spec.version       = RSpec::DocumentRequests::VERSION
  spec.authors       = ["Oded Niv"]
  spec.email         = ["oded.niv@gmail.com"]

  spec.summary       = %q{Automatically documents requests generated by RSpec examples.}
  spec.description   = %q{Use this gem to document your API with your specs.}
  spec.homepage      = "https://github.com/odedniv/rspec-document_requests"
  spec.license       = "Unlicense"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"
  spec.add_runtime_dependency "rspec-rails", "~> 6.1"

  spec.add_development_dependency "bundler", "~> 2.5"
  spec.add_development_dependency "rake", "~> 13.2"
end
