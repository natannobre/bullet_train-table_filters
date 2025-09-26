# frozen_string_literal: true

module BulletTrain
  module TableFilters
    class Engine < ::Rails::Engine
      isolate_namespace BulletTrain::TableFilters

      config.before_configuration do
        # Add engine's locale files to I18n load path
        config.i18n.load_path += Dir[root.join("config", "locales", "**", "*.{rb,yml}")]
      end

      initializer "bullet_train_table_filters.view_paths", after: :add_view_paths do |app|
        # Add engine's view directory to the view path
        engine_view_path = root.join("app", "views")

        unless app.config.paths["app/views"].expanded.include?(engine_view_path.to_s)
          app.config.paths["app/views"] << engine_view_path
        end
      end
    end
  end
end
