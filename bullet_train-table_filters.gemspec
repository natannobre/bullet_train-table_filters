require_relative "lib/bullet_train/table_filters/version"

Gem::Specification.new do |spec|
  spec.name        = "bullet_train-table_filters"
  spec.version     = BulletTrain::TableFilters::VERSION
  spec.authors     = [ "Natan Nobre Chaves" ]
  spec.email       = [ "natannobre37@gmail.com" ]
  spec.homepage    = "https://github.com/natannobre/bullet_train-table_filters"
  spec.summary     = "Column-based table filtering for Bullet Train applications"
  spec.description = "A Rails engine that provides flexible column-based filtering"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.0"
end
