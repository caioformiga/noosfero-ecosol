class Folder < Article

  acts_as_having_settings :field => :setting

  settings_items :view_as, :type => :string, :default => 'folder'

  def self.select_views
    [[_('Folder'), 'folder'], [_('Image gallery'), 'image_gallery']]
  end

  def self.views
    select_views.map(&:last)
  end

  validates_inclusion_of :view_as, :in => self.views

  def self.short_description
    _('Folder')
  end

  def self.description
    _('A folder, inside which you can put other articles.')
  end

  def icon_name
    'folder'
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::AssetTagHelper
  include FolderHelper
  include DatesHelper

  def to_html
    send(view_as)
  end

  def folder
    content_tag('div', body) + tag('hr') + (children.empty? ? content_tag('em', _('(empty folder)')) : list_articles(children))
  end

  def image_gallery
    article = self
    lambda do
      render :file => 'content_viewer/image_gallery', :locals => {:article => article}
    end
  end

  def folder?
    true
  end

  def display_as_gallery?
    view_as == 'image_gallery'
  end

  def can_display_hits?
    false
  end

  def accept_comments?
    false
  end

  has_many :images, :class_name => 'Article',
                    :foreign_key => 'parent_id',
                    :order => 'type, name',
                    :conditions => ['type = ? and content_type in (?) or type = ?', 'UploadedFile', UploadedFile.content_types, 'Folder']

end
