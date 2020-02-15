# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name     = 'jekyll-site-tree'
  s.summary  = 'compile typescript files on your jekyll blog.'
  s.license  = 'MIT'
  s.authors  = ['Mohsin Kaleem']
  s.email    = 'mohkalsin@gmail.com'
  s.require_paths = ['lib']

  s.add_dependency 'jekyll', '~> 3.8'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'

  s.description = <<EOF
provides automatic compilation of typescript files to javascript
files for your jekyll blog.
EOF
end
