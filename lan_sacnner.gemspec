# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lan_scanner/version'

Gem::Specification.new do |spec|
  spec.name          = "lan_scanner"
  spec.version       = LanScanner::VERSION
  spec.authors       = ["Matthäus J. N. Beyrle"]
  spec.email         = ["lan_scanner.gemspec@mail.magynhard.de"]

  spec.summary       = %q{The ruby gem to scan your LAN for devices}
  spec.homepage      = "https://github.com/magynhard/lan_scanner"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency     'tty-which',  '~> 0.5'
  spec.add_runtime_dependency     'tmpdir',     '~> 0.1.3'
  spec.add_runtime_dependency     'nokogiri',   '~> 1.15'

  spec.add_development_dependency 'bundler',    '~> 2.0'
  spec.add_development_dependency 'rake',       '>= 10.0'
  spec.add_development_dependency 'rspec',      '>= 3.0'
end
