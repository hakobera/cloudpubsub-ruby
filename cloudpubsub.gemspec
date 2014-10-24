# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudpubsub/version'

Gem::Specification.new do |spec|
  spec.name          = "cloudpubsub"
  spec.version       = CloudPubSub::VERSION
  spec.authors       = ["Kazuyuki Honda"]
  spec.email         = ["hakobera@gmail.com"]
  spec.summary       = %q{This library is a wrapper for Google Cloud Pub/Sub}
  spec.description   = %q{This library is a wrapper for Google Cloud Pub/Sub}
  spec.homepage      = "https://github.com/hakobera/cloud-pubsub-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency  "google-api-client", "~> 0.7.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
end
