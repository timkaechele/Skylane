
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flung/version"

Gem::Specification.new do |spec|
  spec.name          = "flung"
  spec.version       = Flung::VERSION
  spec.authors       = ["Tim Kächele"]
  spec.email         = ["mail@timkaechele.me"]

  spec.summary       = "A json rpc server for ruby"
  spec.description   = "A json-rpc server that uses rack and ruby metaprogramming magic."
  spec.homepage      = "https://github.com/timkaechele/flung"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
  spec.add_development_dependency "simplecov", "~> 0.16"

  spec.add_dependency "method_source", "~> 0.9"
  spec.add_dependency "rack", "~> 2.0"

end
