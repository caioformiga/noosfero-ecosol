class QualifierCertifier < ActiveRecord::Base

  default_scope :include => [:qualifier, :certifier]

  belongs_to :qualifier
  belongs_to :certifier

  validates_presence_of :qualifier

end
