# frozen_string_literal: true

module BulletTrain
  module TableFilters
    class ModelGenerator
      attr_reader :model_name, :parent_model, :field_specs, :app_root

      def initialize(model_name:, parent_model:, field_specs: [])
        @model_name = model_name
        @parent_model = parent_model
        @field_specs = field_specs
        @app_root = Rails.root
        @timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      end

      def generate
        # validate_models
        # parse_field_specifications
        # generate_controller_code
        # generate_view_code
        # generate_partial_override if has_custom_fields?
        # show_integration_instructions
      end

      private

      def validate_models
        # Check if models exist
        begin
          model_name.constantize
        rescue NameError
          puts "⚠️  Warning: Model '#{model_name}' not found. Make sure it exists."
        end

        begin
          parent_model.constantize
        rescue NameError
          puts "⚠️  Warning: Model '#{parent_model}' not found. Make sure it exists."
        end
      end

      def parse_field_specifications
        @parsed_fields = {}

        field_specs.each do |spec|
          if spec.include?(":")
            field_name, field_type = spec.split(":", 2)
            rails_type = map_field_type_to_rails(field_type)

            @parsed_fields[field_name.to_sym] = {
              type: rails_type,
              label: field_name.humanize,
              original_spec: field_type
            }
          end
        end

        # If no fields specified, try to detect from model
        if @parsed_fields.empty?
          @parsed_fields = detect_model_fields
        end
      end

      def map_field_type_to_rails(field_type)
        case field_type
        when "text_field", "email_field", "password_field"
          :string
        when "text_area"
          :text
        when "number_field"
          :integer
        when "date_field"
          :date
        when "datetime_field", "datetime_local_field"
          :datetime
        when "check_box"
          :boolean
        when "select", "collection_select"
          :select
        else
          :string
        end
      end

      def detect_model_fields
        model_class = model_name.constantize
        return {} unless model_class.respond_to?(:columns)

        fields = {}
        model_class.columns.each do |column|
          next if column.name.in?(%w[id created_at updated_at])

          fields[column.name.to_sym] = {
            type: column.type,
            label: column.name.humanize,
            original_spec: "#{column.type}_field"
          }
        end

        fields
      rescue NameError
        {}
      end

      def generate_controller_code
        controller_name = model_name.pluralize.underscore
        controller_path = "#{app_root}/tmp/table_filters_#{controller_name}_controller_#{@timestamp}.rb"

        controller_code = <<~RUBY
          # Generated controller code for #{model_name} table filters
          # Add this to: app/controllers/account/#{controller_name}_controller.rb

          class Account::#{controller_name.camelize}Controller < Account::ApplicationController
            account_load_and_authorize_resource :#{model_name.underscore},#{' '}
                                               through: :team,#{' '}
                                               through_association: :#{controller_name}

            def index
              # Apply table filters
              @#{controller_name} = apply_table_filters(@#{controller_name})
          #{'    '}
              # Add any additional includes/scopes
              @#{controller_name} = @#{controller_name}.includes(:#{parent_model.underscore}) # Adjust as needed
          #{'    '}
              # Pagination (if using Kaminari)
              @#{controller_name} = @#{controller_name}.page(params[:page]) if defined?(Kaminari)
            end
          end
        RUBY

        File.write(controller_path, controller_code)
        puts "  ✓ Controller code: #{controller_path}"
      end

      def generate_view_code
        view_name = model_name.pluralize.underscore
        view_path = "#{app_root}/tmp/table_filters_#{view_name}_view_#{@timestamp}.erb"

        # Generate the table_filters_for call
        filters_config = generate_filters_config

        view_code = <<~ERB
          <!-- Generated view code for #{model_name} table filters -->
          <!-- Add this to: app/views/account/#{view_name}/index.html.erb -->

          <%= render 'account/shared/breadcrumbs', breadcrumbs: [
            link_to("Dashboard", account_dashboard_path),
            "#{model_name.pluralize.humanize}"
          ] %>

          <div class="row">
            <div class="col">
              <h1 class="pb-2 mt-0 mb-4 border-bottom">
                #{model_name.pluralize.humanize}
              </h1>
            </div>
            <div class="col-auto">
              <%= link_to "New #{model_name.humanize}",#{' '}
                          new_account_team_#{model_name.underscore}_path(@team),#{' '}
                          class: "btn btn-primary" %>
            </div>
          </div>

          <!-- Table Filters -->
          <%= table_filters_for(#{model_name}, columns: {
          #{filters_config}
          }) %>

          <!-- Your existing table code here -->
          <div class="card">
            <% if @#{view_name}.any? %>
              <table class="table">
                <thead>
                  <tr>
          #{generate_table_headers}
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <% @#{view_name}.each do |#{model_name.underscore}| %>
                    <tr>
          #{generate_table_cells}
                      <td>
                        <%= link_to "Edit",#{' '}
                                    edit_account_team_#{model_name.underscore}_path(@team, #{model_name.underscore}),#{' '}
                                    class: "btn btn-sm btn-primary" %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
          #{'    '}
              <%= paginate @#{view_name} if defined?(Kaminari) %>
            <% else %>
              <div class="card-body text-center">
                <p class="text-muted">No #{model_name.humanize.downcase.pluralize} found.</p>
                <%= link_to "Create the first #{model_name.humanize.downcase}",#{' '}
                            new_account_team_#{model_name.underscore}_path(@team),#{' '}
                            class: "btn btn-primary" %>
              </div>
            <% end %>
          </div>
        ERB

        File.write(view_path, view_code)
        puts "  ✓ View code: #{view_path}"
      end

      def generate_filters_config
        return "    # No fields specified" if @parsed_fields.empty?

        @parsed_fields.map do |field_name, field_data|
          if field_data[:type] == :select
            "    #{field_name}: { type: :select, label: \"#{field_data[:label]}\", options: [] } # Configure options"
          else
            "    #{field_name}: { type: :#{field_data[:type]}, label: \"#{field_data[:label]}\" }"
          end
        end.join(",\n")
      end

      def generate_table_headers
        return "            <!-- Add your table headers -->" if @parsed_fields.empty?

        @parsed_fields.map do |field_name, field_data|
          "            <th>#{field_data[:label]}</th>"
        end.join("\n")
      end

      def generate_table_cells
        return "            <!-- Add your table cells -->" if @parsed_fields.empty?

        @parsed_fields.map do |field_name, field_data|
          case field_data[:type]
          when :date, :datetime
            "            <td><%= #{model_name.underscore}.#{field_name}&.strftime(\"%B %d, %Y\") %></td>"
          when :boolean
            "            <td><%= #{model_name.underscore}.#{field_name}? ? \"Yes\" : \"No\" %></td>"
          else
            "            <td><%= #{model_name.underscore}.#{field_name} %></td>"
          end
        end.join("\n")
      end

      def generate_partial_override
        # Generate custom partial for complex field types
        puts "  ✓ Custom partial needed for: #{@parsed_fields.keys.join(', ')}"
      end

      def has_custom_fields?
        @parsed_fields.values.any? { |field| field[:type] == :select }
      end

      def show_integration_instructions
        puts ""
        puts "🔧 Integration Instructions:"
        puts ""
        puts "1. Copy the controller code and integrate it into your existing controller"
        puts "2. Copy the view code and add the filters to your existing view"
        puts "3. Make sure your model has the necessary associations:"
        puts "   - #{model_name} belongs_to :#{parent_model.underscore}"
        puts "   - #{parent_model} has_many :#{model_name.pluralize.underscore}"
        puts ""

        if has_custom_fields?
          puts "4. Configure select field options in the view:"
          @parsed_fields.each do |field_name, field_data|
            if field_data[:type] == :select
              puts "   - #{field_name}: Add appropriate options array"
            end
          end
          puts ""
        end

        puts "5. Test the filters by running your Rails server and visiting the #{model_name.pluralize.underscore} page"
      end
    end
  end
end
