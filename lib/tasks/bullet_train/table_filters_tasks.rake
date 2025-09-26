# frozen_string_literal: true

namespace :bullet_train do
  namespace :table_filters do
    desc "Install table filters into your Bullet Train application"
    task install: :environment do
      puts "🔧 Installing Bullet Train Table Filters Engine..."
      puts ""

      app_js_dir = Rails.root.join("app", "javascript")
      app_views_dir = Rails.root.join("app", "views")
      app_locales_dir = Rails.root.join("config", "locales", "en")
      engine_js_dir = BulletTrain::TableFilters::Engine.root.join("app", "javascript")
      engine_views_dir = BulletTrain::TableFilters::Engine.root.join("app", "views")
      engine_locales_dir = BulletTrain::TableFilters::Engine.root.join("config", "locales", "en")

      # copy app/javascript/bullet_train/table_filters/controllers/filter_toggle_controller.js
      # to app/javascript/controllers/
      if File.exist?(app_js_dir.join("controllers", "filter_toggle_controller.js"))
        puts "⚠️  Warning: #{app_js_dir.join("controllers", "filter_toggle_controller.js")} already exists."
        print "Do you want to overwrite it? (y/n): "
        answer = STDIN.gets.chomp.downcase
        if answer == "y"
          FileUtils.cp(engine_js_dir.join("bullet_train", "table_filters", "controllers", "filter_toggle_controller.js"),
                       app_js_dir.join("controllers", "filter_toggle_controller.js"))
          puts "✅ Copied filter_toggle_controller.js to #{app_js_dir.join("controllers", "filter_toggle_controller.js")}"
        else
          puts "Skipping copy to avoid overwriting existing file."
        end
      else
        FileUtils.cp(engine_js_dir.join("bullet_train", "table_filters", "controllers", "filter_toggle_controller.js"),
                     app_js_dir.join("controllers", "filter_toggle_controller.js"))
        puts "✅ Copied filter_toggle_controller.js to #{app_js_dir.join("controllers", "filter_toggle_controller.js")}"
      end

      # copy app/javascript/bullet_train/table_filters/controllers/search_controller.js
      # to app/javascript/controllers/
      if File.exist?(app_js_dir.join("controllers", "search_controller.js"))
        puts "⚠️  Warning: #{app_js_dir.join("controllers", "search_controller.js")} already exists."
        print "Do you want to overwrite it? (y/n): "
        answer = STDIN.gets.chomp.downcase
        if answer == "y"
          FileUtils.cp(engine_js_dir.join("bullet_train", "table_filters", "controllers", "search_controller.js"),
                       app_js_dir.join("controllers", "search_controller.js"))
          puts "✅ Copied search_controller.js to #{app_js_dir.join("controllers", "search_controller.js")}"
        else
          puts "Skipping copy to avoid overwriting existing file."
        end
      else
        FileUtils.cp(engine_js_dir.join("bullet_train", "table_filters", "controllers", "search_controller.js"),
                     app_js_dir.join("controllers", "search_controller.js"))
        puts "✅ Copied search_controller.js to #{app_js_dir.join("controllers", "search_controller.js")}"
      end

      # copy app/views/bullet_train/table_filters/shared/_search_form.html.erb
      # to app/views/account/filter/
      if File.exist?(app_views_dir.join("account", "filter", "_search_form.html.erb"))
        puts "⚠️  Warning: #{app_views_dir.join("account", "filter", "_search_form.html.erb")} already exists."
        print "Do you want to overwrite it? (y/n): "
        answer = STDIN.gets.chomp.downcase
        if answer == "y"
          FileUtils.mkdir_p(app_views_dir.join("account", "filter"))
          FileUtils.cp(engine_views_dir.join("bullet_train", "table_filters", "shared", "_search_form.html.erb"),
                       app_views_dir.join("account", "filter", "_search_form.html.erb"))
          puts "✅ Copied _search_form.html.erb to #{app_views_dir.join("account", "filter", "_search_form.html.erb")}"
        else
          puts "Skipping copy to avoid overwriting existing file."
        end
      else
        FileUtils.mkdir_p(app_views_dir.join("account", "filter"))
        FileUtils.cp(engine_views_dir.join("bullet_train", "table_filters", "shared", "_search_form.html.erb"),
                     app_views_dir.join("account", "filter", "_search_form.html.erb"))
        puts "✅ Copied _search_form.html.erb to #{app_views_dir.join("account", "filter", "_search_form.html.erb")}"
      end

      # copy config/locales/en.yml
      # to config/locales/table_filters.en.yml
      if File.exist?(app_locales_dir.join("table_filters.en.yml"))
        puts "⚠️  Warning: #{app_locales_dir.join("table_filters.en.yml")} already exists."
        print "Do you want to overwrite it? (y/n): "
        answer = STDIN.gets.chomp.downcase
        if answer == "y"
          FileUtils.cp(engine_locales_dir.join("filter.en.yml"),
                       app_locales_dir.join("table_filters.en.yml"))
          puts "✅ Copied filter.en.yml to #{app_locales_dir.join("table_filters.en.yml")}"
        else
          puts "Skipping copy to avoid overwriting existing file."
        end
      else
        FileUtils.cp(engine_locales_dir.join("filter.en.yml"),
                     app_locales_dir.join("table_filters.en.yml"))
        puts "✅ Copied filter.en.yml to #{app_locales_dir.join("table_filters.en.yml")}"
      end

      # find the file app/controllers/account/application_controller.rb
      application_controller_path = Rails.root.join("app", "controllers", "account", "application_controller.rb")
      if File.exist?(application_controller_path)
        application_controller_code = File.read(application_controller_path)
        unless application_controller_code.include?("include Account::TableFilters::Base")
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
        else
          puts "✅ Account::ApplicationController already includes Account::TableFilters::Base. Skipping patch."
        end
      else
        puts "❌ Could not find Account::ApplicationController at #{application_controller_path}. Please add `include Account::TableFilters::Base` manually."
      end

      puts ""
      puts "✅ Installation complete!"
      puts ""
    end

    desc "Generate table filters for a specific model"
    task generate: :environment do
      # Parse ARGV directly
      args = ARGV.select { |arg| !arg.start_with?("-") && arg != "bullet_train:table_filters:generate" }

      if args.length < 2
        puts "❌ Usage: rake bullet_train:table_filters:generate Payment Team name:text_field description:text_field expiration:date_field"
        puts ""
        puts "Alternative usage with environment variables:"
        puts "MODEL=Payment PARENT=Team FIELDS=\"name:text_field,description:text_field\" rake bullet_train:table_filters:generate"
        exit 1
      end

      model_name = args[0] || ENV["MODEL"]
      parent_model = args[1] || ENV["PARENT"]

      # Get field specs from remaining args or ENV
      if args.length > 2
        field_specs = args[2..-1]
      elsif ENV["FIELDS"]
        field_specs = ENV["FIELDS"].split(",").map(&:strip)
      else
        field_specs = []
      end

      puts "🎯 Generating table filters for #{model_name}..."
      puts "   Parent model: #{parent_model}"
      puts "   Fields: #{field_specs.join(', ')}" if field_specs.any?

      # Load the generator
      require "bullet_train/table_filters/model_generator"

      generator = BulletTrain::TableFilters::ModelGenerator.new(
        model_name: model_name,
        parent_model: parent_model,
        field_specs: field_specs
      )

      begin
        generator.generate
        puts "✅ Generated table filters for #{model_name}!"
      rescue => e
        puts "❌ Error generating filters: #{e.message}"
        puts e.backtrace.first(5).join("\n") if ENV["DEBUG"]
      end

      # Prevent rake from treating field specs as tasks
      field_specs.each { |spec| task spec.to_sym do ; end }
      exit 0
    end
  end
end
