# BulletTrain::TableFilters

A Rails engine that provides flexible, column-based filtering for Bullet Train applications. This gem enables you to easily add dynamic search and filtering capabilities to your data tables with a clean, responsive UI and real-time search functionality.

PS: This is not an official Bullet Train gem.

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0.0-red.svg?style=flat&logo=ruby)](https://www.ruby-lang.org/en/downloads/)
[![Rails](https://img.shields.io/badge/rails-%3E%3D%208.0.0-blue.svg?style=flat&logo=ruby-on-rails)](https://rubyonrails.org/)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)



## Features

- **Dynamic Column Filtering**: Filter table data by any model attribute
- **Real-time Search**: Debounced search input with configurable delay (default 300ms)
- **Toggleable Filter UI**: Collapsible filter form with smooth toggle animation
- **Turbo Frame Support**: Seamless integration with Hotwire Turbo for fast, Ajax-like updates
- **Internationalization**: Built-in I18n support with customizable labels and placeholders
- **Flexible Integration**: Easy to integrate with existing Bullet Train controllers
- **Responsive Design**: Mobile-friendly filter interface with Tailwind CSS styling
- **Safe SQL**: Automatic SQL sanitization to prevent injection attacks

## Installation

Add this line to your application's Gemfile:

```ruby
gem "bullet_train-table_filters"
```

And then execute:

```bash
$ bundle install
```

Then run the installer:

```bash
$ rails generate bullet_train:table_filters:install
```

## Usage

### 1. Include the Controller Concern

In your controller, include the `#available_filter_attributes` private method to define which attributes can be filtered:

```ruby
class Account::ProjectsController < ApplicationController
  account_load_and_authorize_resource :project, through: :team, through_association: :projects

  # GET /account/teams/:team_id/projects
  # GET /account/teams/:team_id/projects.json
  def index
    delegate_json_to_api
  end
  
  private

  def available_filter_attributes
    %w[name description]
  end
end
```

### 2. Add the Filter Form to Your View

In your index (in our example `app/views/account/projects/_index.html.erb`) view:
 - Move the pagy controls inside the turbo frame
 - Inside the `box.description` render the search form partial
 - Wrap your table in a turbo frame with the same ID as the one passed to the search form

```erb
<% projects = projects.accessible_by(current_ability) %>
<% team = @team %>
<% context ||= team %>
<% collection ||= :projects %>
<% hide_actions ||= false %>
<% hide_back ||= false %>

<%= action_model_select_controller do %>
  <% cable_ready_updates_for context, collection do %>
    <%= render 'account/shared/box' do |box| %>
      <% box.title t(".contexts.#{context.class.name.underscore}.header") %>
      <% box.description do %>
        <%= t(".contexts.#{context.class.name.underscore}.description#{"_empty" unless projects.any?}") %>
        <%= render "shared/limits/index", model: projects.model %>
        <%= render "account/filter/search_form",
                   collection: projects,
                   url: account_team_projects_path(@team),
                   turbo_frame: "projects",
                   attributes: { name: :text, description: :text } %>
      <% end %>

      <% box.table do %>
        <%= turbo_frame_tag "projects" do %>
          <% pagy ||= nil %>
          <% pagy, projects = pagy(projects, page_param: :projects_page) unless pagy %>

          <% if projects.any? %>
            <table class="table">
              <thead>
                <tr>
                  <%= render "shared/tables/select_all" %>
                  <th><%= t('.fields.name.heading') %></th>
                  <th><%= t('.fields.description.heading') %></th>
                  <%# 🚅 super scaffolding will insert new field headers above this line. %>
                  <th><%= t('.fields.created_at.heading') %></th>
                  <th class="text-right"></th>
                </tr>
              </thead>
              <tbody>
                <%= render partial: 'account/projects/project', collection: projects %>
              </tbody>
            </table>
          <% end %>

          <% if defined?(pagy) && pagy %>
            <div class="m-4 flex justify-end">
              <%== pagy_nav(pagy) if pagy.pages > 1 %>
            </div>
          <% end %>
        <% end %>
      <% end %>

      <% box.actions do %>
        <% unless hide_actions %>
          <% if context == team %>
            <% if can? :create, Project.new(team: team) %>
              <%= link_to t('.buttons.new'), [:new, :account, team, :project], class: "#{first_button_primary(:project)} new" %>
            <% end %>
          <% end %>

          <%# 🚅 super scaffolding will insert new targets one parent action model buttons above this line. %>
          <%# 🚅 super scaffolding will insert new bulk action model buttons above this line. %>
          <%= render "shared/bulk_action_select" if projects.any? %>

          <% unless hide_back %>
            <%= link_to t('global.buttons.back'), [:account, context], class: "#{first_button_primary(:project)} back" %>
          <% end %>
        <% end %>
      <% end %>

      <% box.raw_footer do %>
        <%# 🚅 super scaffolding will insert new action model index views above this line. %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### Internationalization

Customize the filter labels and placeholders in your locale files:

## How It Works

1. **Controller Integration**: The `Account::TableFilters::Base` concern automatically applies filters to your model scope based on URL parameters
2. **Safe Filtering**: All filter values are sanitized using `ActiveRecord::Base.sanitize_sql_like` to prevent SQL injection
3. **Real-time Updates**: The JavaScript controllers handle form submission with debouncing and Turbo Frame updates
4. **Pattern Matching**: Filters use SQL `LIKE` queries with wildcards for flexible text matching

## Requirements

- Rails >= 8.0.0
- Hotwire Turbo
- Stimulus (for JavaScript functionality)
- Bullet Train framework

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/natannobre/bullet_train-table_filters.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
