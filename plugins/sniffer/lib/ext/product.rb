require_dependency '../../../../app/models/product'

class Product
  KM_LAT = 111.2 # aproximate distance in km for 1 degree latitude
  KM_LNG = 85.3 #aproximate distance in km for 1 degree longitude


  #products x inputs
  named_scope :suppliers_products, lambda { |enterprise|
    {
    :select => "DISTINCT products_2.id, products_2.name, products.id as my_product_id, products.name as my_product_name,
      profiles.id as profile_id, profiles.identifier as profile_identifier, profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
      inputs.product_category_id, categories.name as product_category_name,
      'supplier_product' as view,
      SQRT( POW((#{KM_LAT} * (#{enterprise.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{enterprise.lng} - profiles.lng)), 2)) AS profile_distance",
    :joins => "INNER JOIN inputs ON ( products.id = inputs.product_id )
      INNER JOIN categories ON ( inputs.product_category_id = categories.id )
      INNER JOIN products products_2 ON ( categories.id = products_2.product_category_id )
      INNER JOIN profiles ON ( profiles.id = products_2.enterprise_id )",
    :conditions => "products.enterprise_id = #{enterprise.id}
      AND profiles.public_profile = true AND profiles.visible = true
      AND profiles.id <> #{enterprise.id}"
    }
  }

  #inputs x products
  named_scope :buyers_products, lambda { |enterprise|
    {
    :select => "DISTINCT products.id, products.name, products_2.id as my_product_id, products_2.name as my_product_name,
      profiles.id as profile_id, profiles.identifier as profile_identifier, profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
      inputs.product_category_id, categories.name as product_category_name,
      'buyer_product' as view,
      SQRT( POW((#{KM_LAT} * (#{enterprise.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{enterprise.lng} - profiles.lng)), 2)) AS profile_distance",
    :joins => "INNER JOIN inputs ON ( products.id = inputs.product_id )
      INNER JOIN categories ON ( inputs.product_category_id = categories.id )
      INNER JOIN products products_2 ON ( categories.id = products_2.product_category_id )
      INNER JOIN profiles ON ( profiles.id = products.enterprise_id )",
    :conditions => "products_2.enterprise_id = #{enterprise.id}
      AND profiles.public_profile = true AND profiles.visible = true
      AND profiles.id <> #{enterprise.id}"
    }
  }

  #interest x products
  named_scope :interests_suppliers_products, lambda { |profile|
    {
    :from => "sniffer_plugin_profiles sniffer",
    :select => "DISTINCT products.id, products.name AS my_product_name,
      profiles.id as profile_id, profiles.identifier as profile_identifier, profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
      categories.id as product_category_id, categories.name as product_category_name,
      'interest_supplier_product' as view,
      SQRT( POW((#{KM_LAT} * (#{profile.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{profile.lng} - profiles.lng)), 2)) AS profile_distance",
    :joins => "INNER JOIN sniffer_plugin_opportunities AS op ON ( sniffer.id = op.profile_id AND op.opportunity_type = 'ProductCategory' )
      INNER JOIN categories ON ( op.opportunity_id = categories.id )
      INNER JOIN products ON ( products.product_category_id = categories.id )
      INNER JOIN profiles ON ( products.enterprise_id = profiles.id )",
    :conditions => "sniffer.enabled = true AND sniffer.profile_id = #{profile.id} AND products.enterprise_id <> #{profile.id}
      AND profiles.public_profile = true AND profiles.visible = true
      AND profiles.id <> #{profile.id}"
    }
  }

  #products x interests
  named_scope :interests_buyers_products, lambda { |profile|
    {
    :select => "DISTINCT products.id, products.name,
      profiles.id as profile_id, profiles.identifier as profile_identifier, profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
      categories.id as product_category_id, categories.name as product_category_name,
      'interest_buyer_product' as view,
      SQRT( POW((#{KM_LAT} * (#{profile.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{profile.lng} - profiles.lng)), 2)) AS profile_distance",
    :joins => "INNER JOIN categories ON ( categories.id = products.product_category_id )
      INNER JOIN sniffer_plugin_opportunities as op ON ( categories.id = op.opportunity_id AND op.opportunity_type = 'ProductCategory' )
      INNER JOIN sniffer_plugin_profiles sniffer ON ( op.profile_id = sniffer.id AND sniffer.enabled = true )
      INNER JOIN profiles ON ( sniffer.profile_id = profiles.id )",
    :conditions => "products.enterprise_id = #{profile.id} 
      AND profiles.public_profile = true AND profiles.visible = true
      AND profiles.id <> #{profile.id}"
    }
  }

  #knowledge x inputs
  named_scope :knowledge_buyers_inputs, lambda { |profile|
    {
    :select => "DISTINCT products.id as my_product_id, products.name as my_product_name,
      profiles.id as profile_id, profiles.identifier as profile_identifier, profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
      inputs.product_category_id, 
      articles.name as knowledge_name, articles.id AS knowledge_id, article_resources.resource_id AS knowledge_category,
      products.enterprise_id AS buyer_id,
      'knowledge_buyer_input' as view,
      SQRT( POW((#{KM_LAT} * (#{profile.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{profile.lng} - profiles.lng)), 2)) AS profile_distance",
    :joins => "INNER JOIN inputs ON ( products.id = inputs.product_id )
      INNER JOIN article_resources ON (article_resources.resource_id = inputs.product_category_id AND article_resources.resource_type = 'ProductCategory')
      INNER JOIN articles ON (article_resources.article_id = articles.id)
      INNER JOIN profiles ON ( products.enterprise_id = profiles.id )",
    :conditions => "articles.type = 'CmsLearningPluginLearning'
      AND articles.profile_id = #{profile.id}
      AND products.enterprise_id <> #{profile.id}"
    }
  }

  #inputs x knowledge
  named_scope :knowledge_suppliers_inputs, lambda { |profile|
     {
    :select => "DISTINCT products.id as my_product_id, products.name as my_product_name,
      profiles.id as profile_id, profiles.identifier as profile_identifier, profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
      inputs.product_category_id, 
      articles.name as knowledge_name, articles.id AS knowledge_id, article_resources.resource_id AS knowledge_category,
      'knowledge_supplier_input' as view,
      SQRT( POW((#{KM_LAT} * (#{profile.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{profile.lng} - profiles.lng)), 2)) AS profile_distance",
    :joins => "INNER JOIN inputs ON ( products.id = inputs.product_id )
      INNER JOIN article_resources ON (article_resources.resource_id = inputs.product_category_id AND article_resources.resource_type = 'ProductCategory')
      INNER JOIN articles ON (article_resources.article_id = articles.id)
      INNER JOIN profiles ON ( articles.profile_id = profiles.id )",
    :conditions => "articles.type = 'CmsLearningPluginLearning'
      AND articles.profile_id <> #{profile.id}
      AND products.enterprise_id = #{profile.id}"
    }
  }

  #knowledge x interests
  named_scope :knowledge_buyers_interests, lambda { |profile|
    {
    :select => "DISTINCT articles.id AS knowledge_id, articles.name AS knowledge_name,
              op.opportunity_id AS product_category_id,
              profiles.id as profile_id, profiles.identifier as profile_identifier, 
              profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
              'knowledge_buyer_interest' as view,
              SQRT( POW((#{KM_LAT} * (#{profile.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{profile.lng} - profiles.lng)), 2)) AS profile_distance",
    :from => "articles",
    :joins =>   "INNER JOIN article_resources ON (articles.id = article_resources.article_id)
               INNER JOIN sniffer_plugin_opportunities as op ON ( article_resources.resource_id = op.opportunity_id AND op.opportunity_type = 'ProductCategory' AND article_resources.resource_type = 'ProductCategory' )
               INNER JOIN sniffer_plugin_profiles sniffer ON ( op.profile_id = sniffer.id AND sniffer.enabled = true )
               INNER JOIN profiles ON ( sniffer.profile_id = profiles.id )",
    :conditions => "articles.profile_id = #{profile.id} 
                  AND profiles.public_profile = true 
                  AND profiles.visible = true
                  AND profiles.id <> #{profile.id}"
    }
  }

  #interests x knowledge
  named_scope :knowledge_suppliers_interests, lambda { |profile|
    {
    :select => "DISTINCT articles.id AS knowledge_id, articles.name AS knowledge_name, articles.profile_id AS wise,
              op.opportunity_id AS product_category_id,
              profiles.id as profile_id, profiles.identifier as profile_identifier, 
              profiles.name as profile_name, profiles.lat as profile_lat, profiles.lng as profile_lng,
              'knowledge_supplier_interest' as view,
              SQRT( POW((#{KM_LAT} * (#{profile.lat} - profiles.lat)), 2) + POW((#{KM_LNG} * (#{profile.lng} - profiles.lng)), 2)) AS profile_distance",
    :from => "articles",
    :joins =>   "INNER JOIN article_resources ON (articles.id = article_resources.article_id)
               INNER JOIN sniffer_plugin_opportunities as op ON ( article_resources.resource_id = op.opportunity_id AND op.opportunity_type = 'ProductCategory' AND article_resources.resource_type = 'ProductCategory' )
               INNER JOIN sniffer_plugin_profiles sniffer ON ( op.profile_id = sniffer.id AND sniffer.enabled = true )
               INNER JOIN profiles ON ( articles.profile_id = profiles.id )",
    :conditions => "articles.profile_id <> #{profile.id} 
                  AND profiles.public_profile = true 
                  AND profiles.visible = true
                  AND sniffer.profile_id = #{profile.id}"
    }
  }

  ########### from here on, methods that try to find individual matches ########################## 

  #search for inputs of supplier that matches the products of producer
  named_scope :products_inputs, lambda { |supplier, producer|
    {
      :select => "products.id, products.name, inputs.id AS input_id, inputs.product_category_id AS input_category_id,
                  products_supplier.name AS products_supplier_name, products_supplier.id AS products_supplier_id", 
      :joins => " INNER JOIN inputs ON (products.id = inputs.product_id) 
                  INNER JOIN categories ON (inputs.product_category_id = categories.id)
                  INNER JOIN products AS products_supplier ON (categories.id = products_supplier.product_category_id)",
      :conditions => "products.enterprise_id = #{producer.id} 
                  AND products_supplier.enterprise_id = #{supplier.id}"
    }
  }

  #search for interests of interested that matches the products of producer
  named_scope :products_interests, lambda { |producer, interested|
    {
    :select => "products.id, products.name, 
      categories.id as product_category_id, categories.name as product_category_name,
      op.opportunity_id",
    :joins => "INNER JOIN categories ON ( categories.id = products.product_category_id )
      INNER JOIN sniffer_plugin_opportunities as op ON ( categories.id = op.opportunity_id AND op.opportunity_type = 'ProductCategory' )
      INNER JOIN sniffer_plugin_profiles sniffer ON ( op.profile_id = sniffer.id AND sniffer.enabled = true )
      INNER JOIN profiles ON ( sniffer.profile_id = profiles.id )",
    :conditions => "products.enterprise_id = #{producer.id} 
      AND profiles.public_profile = true AND profiles.visible = true
      AND profiles.id = #{interested.id}"
    }
  }


  #search for inputs of producer that matches the knowledges of wise
  named_scope :knowledges_inputs, lambda { |wise, producer|
    {
      :select => "inputs.product_category_id AS input_cat, products.name AS product, products.product_category_id AS product_cat,
                  articles.id AS id, articles.name AS knowledge_name, article_resources.resource_id AS knowledge_category",
      :joins => "INNER JOIN inputs ON (products.id = inputs.product_id) 
                 INNER JOIN article_resources ON (article_resources.resource_id = inputs.product_category_id AND article_resources.resource_type = 'ProductCategory')
               INNER JOIN articles ON (article_resources.article_id = articles.id)",
      :conditions => "articles.type = 'CmsLearningPluginLearning'
                    AND articles.profile_id = #{wise.id}
                    AND products.enterprise_id = #{producer.id}"
   }
  }

end
