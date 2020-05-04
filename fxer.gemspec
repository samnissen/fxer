# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fxer/version"

Gem::Specification.new do |spec|
  spec.name          = "fxer"
  spec.version       = Fxer::VERSION
  spec.authors       = ["Sam Nissen"]
  spec.email         = ["scnissen@gmail.com"]

  spec.summary       = "Convert currency based on external sources' rates"
  spec.homepage      = "https://github.com/samnissen/fxer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 5.2.3"

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", "~> 13.0.1"
  spec.add_development_dependency "rake-release", "~> 1.2"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "nokogiri", "~> 1.10"
end
