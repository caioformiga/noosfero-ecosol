module DistributionPlugin::DistributionProductHelper

  include DistributionPlugin::DistributionDisplayHelper
  include DistributionPlugin::SessionHelper

  def supplier_select(f, node, selected_supplier, new_record)
   field_options = !new_record ? {:disabled => 'disabled'} :
     {:onchange => "distribution.our_product.add_change_supplier(this, '#{url_for(:controller => :distribution_plugin_product, :action => :new)}');"}

   options = {}
   options[:selected] = selected_supplier.id if selected_supplier
   options[:include_blank] = true

   labelled_field f, :supplier_id, I18n.t('distribution_plugin.lib.distribution_product_helper.product_from_which_su'),
     f.select(:supplier_id, supplier_choices(node), options, field_options), :class => 'product-supplier'
  end

  def supplier_choices(node)
    @supplier_choices ||= node.suppliers.map do |s|
      [s.name, s.id]
    end.sort{ |a,b| a[0].downcase <=> b[0].downcase }
  end

end
