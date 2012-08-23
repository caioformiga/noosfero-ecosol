class ProductQualifier < ActiveRecord::Base

  default_scope :include => [:qualifier, :certifier]

  belongs_to :qualifier
  belongs_to :product
  belongs_to :certifier

end
