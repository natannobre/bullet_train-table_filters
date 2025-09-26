# frozen_string_literal: true

require "fileutils"

module BulletTrain
  module TableFilters
    class Installer
      def initialize
        @app_js_dir = Rails.root.join("app", "javascript")
        @app_views_dir = Rails.root.join("app", "views")
        @app_locales_dir = Rails.root.join("config", "locales", "en")
        @engine_js_dir = BulletTrain::TableFilters::Engine.root.join("app", "javascript")
        @engine_views_dir = BulletTrain::TableFilters::Engine.root.join("app", "views")
        @engine_locales_dir = BulletTrain::TableFilters::Engine.root.join("config", "locales", "en")
      end

      def install
        puts "🔧 Installing Bullet Train Table Filters Engine..."
        puts ""

        copy_javascript_controllers
        copy_view_templates
        copy_locale_files
        patch_application_controller

        puts ""
        puts "✅ Installation complete!"
        puts ""
      end

      private

      def copy_javascript_controllers
        copy_file_with_confirmation(
          @engine_js_dir.join("bullet_train", "table_filters", "controllers", "table_filters_controller.js"),
          @app_js_dir.join("controllers", "table_filters_controller.js"),
          "table_filters_controller.js"
        )
      end

      def copy_view_templates
        destination_dir = @app_views_dir.join("account", "table_filters")
        FileUtils.mkdir_p(destination_dir)

        copy_file_with_confirmation(
          @engine_views_dir.join("bullet_train", "table_filters", "shared", "_search_form.html.erb"),
          destination_dir.join("_search_form.html.erb"),
          "_search_form.html.erb"
        )
      end

      def copy_locale_files
        copy_file_with_confirmation(
          @engine_locales_dir.join("table_filters.en.yml"),
          @app_locales_dir.join("table_filters.en.yml"),
          "table_filters.en.yml → table_filters.en.yml"
        )
      end

      def patch_application_controller
        application_controller_path = Rails.root.join("app", "controllers", "account", "application_controller.rb")

        unless File.exist?(application_controller_path)
          puts "❌ Could not find Account::ApplicationController at #{application_controller_path}. Please add `include Account::TableFilters::Base` manually."
          return
        end

        application_controller_code = File.read(application_controller_path)

        if application_controller_code.include?("include Account::TableFilters::Base")
          puts "✅ Account::ApplicationController already includes Account::TableFilters::Base. Skipping patch."
          return
        end

        puts "🔍 Patching Account::ApplicationController to include Account::TableFilters::Base..."

        lines = application_controller_code.lines
        insert_index = lines.find_index { |line| line =~ /class Account::ApplicationController/ }

        if insert_index
          insert_index += 2
          lines.insert(insert_index, "  include Account::TableFilters::Base\n")
          File.write(application_controller_path, lines.join)
          puts "✅ Patched Account::ApplicationController!"
        else
          puts "❌ Could not find class definition in Account::ApplicationController. Please add `include Account::TableFilters::Base` manually."
        end
      end

      def copy_file_with_confirmation(source_path, destination_path, display_name)
        if File.exist?(destination_path)
          puts "⚠️  Warning: #{destination_path} already exists."
          if prompt_for_overwrite
            FileUtils.cp(source_path, destination_path)
            puts "✅ Copied #{display_name} to #{destination_path}"
          else
            puts "Skipping copy to avoid overwriting existing file."
          end
        else
          FileUtils.cp(source_path, destination_path)
          puts "✅ Copied #{display_name} to #{destination_path}"
        end
      end

      # Prompt user for overwrite confirmation
      def prompt_for_overwrite
        print "Do you want to overwrite it? (y/n): "
        answer = STDIN.gets.chomp.downcase
        answer == "y"
      end
    end
  end
end
