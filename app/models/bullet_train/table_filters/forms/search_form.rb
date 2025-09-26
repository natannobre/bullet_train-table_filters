class BulletTrain::TableFilters::Forms::SearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def initialize(attributes = {})
    attributes.each do |key, value|
      unless self.class.attribute_names.include?(key.to_s)
        if value.is_a?(Array)
          self.class.attribute key, :string, array: true, default: []
        else
          self.class.attribute key, :string
        end
      end
    end

    super(attributes.to_h)
  end

  def respond_to_missing?(method_name, include_private = false)
    self.class.attribute_names.include?(method_name.to_s) || super
  end

  def method_missing(method_name, *args)
    if self.class.attribute_names.include?(method_name.to_s)
      read_attribute(method_name)
    else
      super
    end
  end
end
