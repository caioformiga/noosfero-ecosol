class DistributionPluginMyprofileController < MyProfileController

  before_filter :load_node

  helper ApplicationHelper
  helper DistributionPlugin::DistributionDisplayHelper

  protected

  def load_node
    @node = DistributionPluginNode.find_or_create profile
    @user_node = DistributionPluginNode.find_or_create current_user.person
  end

  def set_admin_action
    @admin_action = true
  end

  def before_contents
    return unless custom_layout?
  end

  def content_classes
    "plugin-distribution plugin-distribution-layout"
  end

  def custom_layout?
    true
  end

end
