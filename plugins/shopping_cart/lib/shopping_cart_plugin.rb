require_dependency 'shopping_cart_plugin/ext/enterprise'
require_dependency 'shopping_cart_plugin/ext/person'

class ShoppingCartPlugin < Noosfero::Plugin

  def self.plugin_name
    "Shopping Basket"
  end

  def self.plugin_description
    _("A shopping basket feature for enterprises")
  end

  def add_to_cart_button(item, enterprise = context.profile)
    if enterprise.shopping_cart && item.available
       lambda {
         link_to(_('Add to basket'), "add:#{item.name}",
           :class => 'cart-add-item',
           :onclick => "Cart.addItem('#{enterprise.identifier}', #{item.id}, this); return false"
         )
       }
    end
  end

  alias :product_info_extras :add_to_cart_button
  alias :catalog_item_extras :add_to_cart_button
  alias :asset_product_extras :add_to_cart_button

  def stylesheet?
    true
  end

  def js_files
    'cart.js'
  end

  def body_beginning
    expanded_template('cart.html.erb',{:cart => context.session[:cart]})
  end

  def control_panel_buttons
    buttons = []
    if context.profile.enterprise?
      buttons << { :title => _('Shopping basket'), :icon => 'shopping-cart-icon', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'edit'} }
    end
    if context.profile.enterprise? && context.profile.shopping_cart
      buttons << { :title => _('Purchase reports'), :icon => 'shopping-cart-purchase-report', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'reports'} }
    end

    buttons
  end
end
