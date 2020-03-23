
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fs3_cloner/version"

Gem::Specification.new do |spec|
  spec.name          = "fs3_cloner"
  spec.version       = Fs3Cloner::VERSION
  spec.authors       = ["Faizal Zakaria"]
  spec.email         = ["fai@code3.io"]

  spec.summary       = %q{S3 cloner},
  spec.description   = %q{S3 cloner for you to backup your s3 bucket, clone it to a different env etc},
  spec.homepage      = "https://github.com/faizalzakaria/fs3_cloner",
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk", "~> 3"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
