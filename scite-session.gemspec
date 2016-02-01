# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scite/session/version'

Gem::Specification.new do |spec|
  spec.name          = "scite-session"
  spec.version       = SciTE::Session::VERSION
  spec.authors       = ["Sergey Baev"]

  spec.summary       = "Restores and arranges multiple SciTE sessions within KDE"
  spec.homepage      = "https://github.com/tinbka/" + spec.name

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.bindir        = "bin"
  spec.executables   = ["scite-session"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  
  spec.add_dependency "rmtools", "~> 2.5.0"
end
