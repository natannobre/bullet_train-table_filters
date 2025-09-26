module Account::TableFilters::Base
  extend ActiveSupport::Concern

  included do
    before_action :apply_filters, only: :index

    helper_method :available_filter_attributes

    def apply_filters
      scope = instance_variable_get("@#{controller_name}")

      if params[:filters].present?
        params[:filters].each do |key, value|
          if available_filter_attributes.include?(key) && value.present?
            sanitized_value = ActiveRecord::Base.sanitize_sql_like(value)
            scope = scope.where(scope.klass.arel_table[key].matches("%#{sanitized_value}%"))
          end
        end
      end

      instance_variable_set("@#{controller_name}", scope)
    end
  end

  private

  def available_filter_attributes
    []
  end
end
