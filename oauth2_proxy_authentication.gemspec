# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2_proxy_authentication/version'

Gem::Specification.new do |s|
  s.name          = 'oauth2_proxy_authentication'
  s.version       = Oauth2ProxyAuthentication::VERSION
  s.authors       = ['Mike Bland']
  s.email         = ['michael.bland@gsa.gov']
  s.summary       = 'Authenticates requests from bitly/oauth2_proxy'
  s.description   = (
    'Authenticates requests proxied by a bitly/oauth2_proxy server ' \
    'using shared-secret HMAC request signatures.'
  )
  s.homepage      = 'https://github.com/18F/oauth2_proxy_authentication_gem'
  s.license       = 'CC0'

  s.files         = `git ls-files -z *.md bin lib`.split("\x0") + [
  ]
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_runtime_dependency 'bundler', '~> 1.10'
  s.add_development_dependency 'go_script', '~> 0.1'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'about_yml'
end
