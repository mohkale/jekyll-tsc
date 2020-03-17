# frozen_string_literal: true

require_relative './lib/jekyll/typescript/version'

Gem::Specification.new do |s|
  s.name     = 'jekyll-tsc'
  s.version  = Jekyll::Typescript::VERSION
  s.summary  = 'compile typescript files on your jekyll blog.'
  s.license  = 'MIT'
  s.authors  = ['Mohsin Kaleem']
  s.email    = 'mohkalsin@gmail.com'
  s.require_paths = ['lib']
  s.files = Dir['lib/**/*.rb']

  s.add_dependency 'jekyll', '>= 3.8', '< 5.0'
  s.add_development_dependency 'bundler', '~> 1.17.2'
  s.add_development_dependency 'rspec', '~> 3.9'

  s.description = <<EOF
  provides automatic compilation of typescript files to javascript
  files for your jekyll blog.
EOF
end
