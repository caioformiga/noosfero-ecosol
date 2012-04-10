class ArticleResource < ActiveRecord::Base
  belongs_to :article

  belongs_to :resource, :polymorphic => true
  belongs_to :product_category, :class_name => 'ProductCategory', :foreign_key => 'resource_id',
    :conditions => ['resource_type = ?', 'ProductCategory']

  belongs_to :person, :class_name => 'Person', :foreign_key => 'resource_id',
    :conditions => ['resource_type = ?', 'Person']
end
