Rails.application.routes.draw do
  mount BulletTrain::TableFilters::Engine => "/bullet_train-table_filters"
end
