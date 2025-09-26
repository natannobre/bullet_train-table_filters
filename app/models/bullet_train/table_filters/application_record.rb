module BulletTrain
  module TableFilters
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
