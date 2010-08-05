Feature: manage products
  As an enterprise owner
  I want to manage my products

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following enterprises
      | identifier | owner | name | enabled |
      | redemoinho | joaosilva | Rede Moinho | true |
    And feature "disable_products_for_enterprises" is disabled on environment

  Scenario: paginate public listing products and services
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category |  name  | description |
      | redemoinho | bicycle  | Bike 1 | bicycle 1  |
      | redemoinho | bicycle  | Bike 2 | bicycle 2  |
      | redemoinho | bicycle  | Bike 3 | bicycle 3  |
      | redemoinho | bicycle  | Bike 4 | bicycle 4  |
      | redemoinho | bicycle  | Bike 5 | bicycle 5  |
      | redemoinho | bicycle  | Bike 6 | bicycle 6  |
      | redemoinho | bicycle  | Bike 7 | bicycle 7  |
      | redemoinho | bicycle  | Bike 8 | bicycle 8  |
      | redemoinho | bicycle  | Bike 9 | bicycle 9  |
      | redemoinho | bicycle  | Bike 10| bicycle 10 |
      | redemoinho | bicycle  | Bike 11| bicycle 11 |
    When I go to /catalog/redemoinho
    Then I should see "Bike 1"
    And I should see "Bike 2"
    And I should see "Bike 3"
    And I should see "Bike 4"
    And I should see "Bike 5"
    And I should see "Bike 6"
    And I should see "Bike 7"
    And I should see "Bike 8"
    And I should see "Bike 9"
    And I should see "Bike 10"
    And I should not see "Bike 11"
    When I follow "Next"
    Then I should see "Bike 11"

  Scenario: listing products and services
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    Then I should see "Listing products and services"

  Scenario: see button to back in categories hierarchy
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    Then I should see "Back to the product listing" link

  Scenario: see toplevel categories
    Given the following product_categories
      | name |
      | Products |
      | Services |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    Then I should see "Products"
    And I should see "Service"

  @selenium
  Scenario: select a toplevel category and see subcategories
    Given the following product_categories
      | name |
      | Products level0 |
    And the following product_categories
      | name | parent |
      | Computers level1 | products-level0 |
      | DVDs level1 | products-level0 |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    And I select "Products level0 »"
    Then I should see "Computers level1"
    And I should see "DVDs level1"

  @selenium
  Scenario: hide subcategories when select other toplevel category
    Given the following product_categories
      | name |
      | Products level0 |
      | Services level0 |
    And the following product_categories
      | name | parent |
      | Computers level1 | products-level0 |
      | Software development level1 | services-level0 |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    And I select "Products level0 »"
    And I select "Computers level1"
    And I select "Services level0 »"
    Then I should see "Software development level1"
    And I should not see "Computers level1"

  @selenium
  Scenario: show hierarchy of categories
    Given the following product_categories
      | name |
      | Products |
    And the following product_category
      | name | parent |
      | Computers | products |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    And I select "Products »"
    And I select "Computers"
    Then I should see "Products → Computers"

  @selenium
  Scenario: show links in hierarchy of categories and not link current category
    Given the following product_category
      | name |
      | Toplevel Product Categories |
    Given the following product_category
      | name | parent |
      | Category Level 1 | toplevel-product-categories |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    And I select "Toplevel Product Categories »"
    And I select "Category Level 1"
    Then I should see "Toplevel Product Categories" link
    And I should not see "Category Level 1" link

  @selenium
  Scenario: save button come initialy disabled
    Given the following product_category
      | name |
      | Only for test |
    And I am logged in as "joaosilva"
    When I go to /myprofile/redemoinho/manage_products/new
    Then the "#save_and_continue" button should not be enabled

  @selenium
  Scenario: enable save button when select one category
    Given the following product_category
      | name |
      | Browsers (accept categories) |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    And I select "Browsers (accept categories)"
    Then the "Save and continue" button should be enabled

  @selenium
  Scenario: dont enable save button when select category with not accept products
    Given the following product_category
      | name | accept_products |
      | Browsers | false |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    And I select "Browsers"
    Then the "#save_and_continue" button should not be enabled

  @selenium
  Scenario: save product
    Given the following product_category
      | name |
      | Bicycle |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    And I select "Bicycle"
    And I press "Save and continue"
    Then I should see "Bicycle"
    And I should see "Change category"

  @selenium
  Scenario: stay on the same place after error on save
    Given the following product_category
      | name |
      | Bicycle |
    Given I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"
    And I follow "New product or service"
    And I select "Bicycle"
    And I press "Save and continue"
    When I follow "Back"
    And I follow "New product or service"
    And I select "Bicycle"
    And I press "Save and continue"
    Then I should be on Rede Moinho's new product page
    And I should see "Bicycle"

  Scenario: a user with permission can see edit links
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name | description |
      | redemoinho | bicycle  | Bike | Red bicycle |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    Then I should see "Change category"
    And I should see "Edit name"
    And I should see "Edit basic information"
    And I should see "Change image"

  Scenario: an allowed user will see a different button when has no basic info
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    Then I should see "Change category"
    And I should see "Edit name"
    And I should see "Add description, price and other basic information"
    And I should see "Change image"

  Scenario: a not logged user cannot see edit links
    Given I am not logged in
    And the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name | description |
      | redemoinho | bicycle  | Bike | Red bicycle |
    When I go to Rede Moinho's page of product Bike
    Then I should not see "Change category"
    And I should not see "Edit name"
    And I should not see "Edit basic information"
    And I should not see "Change image"

  Scenario: a not allowed user cannot see edit links
    Given the following users
      | login       | name         |
      | mariasantos | Maria Santos |
    And the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name | description |
      | redemoinho | bicycle  | Bike | Red bicycle |
    And I am logged in as "mariasantos"
    When I go to Rede Moinho's page of product Bike
    Then I should not see "Change category"
    And I should not see "Edit name"
    And I should not see "Edit basic information"
    And I should not see "Change image"

  @selenium
  Scenario: edit name of a product
    Given the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Edit name"
    And I fill in "product_name" with "Red bicycle"
    And I press "Save"
    Then I should see "Red bicycle"
    And I should be on Rede Moinho's page of product Red bicycle

  @selenium
  Scenario: cancel edition of a product name
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Edit name"
    When I follow "Cancel"
    Then I should see "Bike"

  @selenium
  Scenario: edit category of a product
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_categories
      | name | parent |
      | Computers | eletronics |
      | DVDs      | eletronics |
    And the following products
      | owner      | category   | name       |
      | redemoinho | computers  | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change category"
    And I select "Eletronics »"
    Then I select "DVDs"
    And I press "Save and continue"
    Then I should see "Eletronics → DVDs"

  @selenium
  Scenario: cancel edition of a product category
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_categories
      | name | parent |
      | Computers | eletronics |
      | DVDs      | eletronics |
    And the following products
      | owner      | category   | name       |
      | redemoinho | computers  | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change category"
    When I follow "Back to product"
    Then I should see "Eletronics → Computers"


  @selenium
  Scenario: edit image of a product
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_categories
      | name | parent |
      | Computers | eletronics |
      | DVDs      | eletronics |
    And the following products
      | owner      | category   | name       |
      | redemoinho | computers  | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change image"
    When I follow "Cancel"
    Then I should be on Rede Moinho's page of product Generic pc

 # FIXME Not working because of tinyMCE plus selenium
 # @selenium
 # Scenario: edit description of a product
 #   Given the following product_category
 #     | name    |
 #     | Bicycle |
 #   And the following products
 #     | owner      | category | name | description       |
 #     | redemoinho | bicycle  | Bike | A new red bicycle |
 #   And I am logged in as "joaosilva"
 #   When I go to Rede Moinho's page of product Bike
 #   Then I should see "A new red bicycle"
 #   And I follow "Edit basic information"
 #   And I type in tinyMCE field "Description" the text "An used red bicycle"
 #   And I press "Save"
 #   Then I should not see "A new red bicycle"
 #   And I should see "An used red bicycle"
 #   And I should be on Rede Moinho's page of product Bike

  @selenium
  Scenario: cancel edition of a product description
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name | description       |
      | redemoinho | bicycle  | Bike | A new red bicycle |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    Then I should see "A new red bicycle"
    And I follow "Edit basic information"
    When I follow "Cancel"
    Then I should see "A new red bicycle"
    And I should be on Rede Moinho's page of product Bike

  @selenium
  Scenario: add an input to a product
   Given the following product_category
      | name |
      | Food |
    And the following product_categories
      | name  | parent |
      | Cake  | food   |
      | Sugar | food   |
    And the following products
      | owner      | category | name           |
      | redemoinho | cake     | Chocolate cake |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Chocolate cake
    And I follow "Add the inputs used by this product"
    And I select "Food »"
    And I select "Sugar"
    And I press "Save and continue"
    Then I should see "Sugar"

  @selenium
  Scenario: cancel addition of a product input
    Given the following product_category
      | name |
      | Food |
    And the following products
      | owner      | category | name |
      | redemoinho | food     | Cake |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Cake
    And I follow "Add the inputs used by this product"
    When I follow "Back to product"
    Then I should see "Cake"