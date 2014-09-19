# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqs_image_processor/version'

Gem::Specification.new do |spec|
  spec.name          = "sqs_image_processor"
  spec.version       = SqsImageProcessor::VERSION
  spec.authors       = ["Neil Turner"]
  spec.email         = ["neil@neilturner.me"]
  spec.summary       = %q{Write a short summary. Required.}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  #spec.executables   = [spec.files.grep(%r{^bin/}) { |f| File.basename(f) }]
  spec.executables   = ["sqs_image_processor"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "recursive-open-struct", "~> 0.5.0"
  spec.add_dependency "aws-sdk-core"  #, "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
