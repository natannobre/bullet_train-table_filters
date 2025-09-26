# frozen_string_literal: true

namespace :bullet_train do
  namespace :table_filters do
    desc "Install table filters into your Bullet Train application"
    task install: :environment do
      installer = BulletTrain::TableFilters::Installer.new
      installer.install
    end
  end
end
