require File.dirname(__FILE__) + '/../test_helper'
require 'test_controller'

# Re-raise errors caught by the controller.
class TestController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < ActionController::TestCase
  all_fixtures
  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_detection_of_environment_by_host
    uses_host 'www.colivre.net'
    get :index

    assert_kind_of Environment, assigns(:environment)

    assert_kind_of Domain, assigns(:domain)
    assert_equal 'colivre.net', assigns(:domain).name

    assert_nil assigns(:profile)
  end

  def test_detect_profile_by_host
    uses_host 'www.jrh.net'
    get :index

    assert_kind_of Environment, assigns(:environment)

    assert_kind_of Domain, assigns(:domain)
    assert_equal 'jrh.net', assigns(:domain).name

    assert_kind_of Profile, assigns(:profile)
  end

  def test_unknown_domain_falls_back_to_default_environment
    uses_host 'veryunprobabledomain.com'

    get :index
    assert_kind_of Environment, assigns(:environment)
    assert assigns(:environment).is_default?
  end

  should 'detect the current environment' do
    default = Environment.default
    Environment.stubs(:default).returns(default)
    default.stubs(:top_url).returns('http://default.com/')

    current = fast_create(Environment, :name => 'test environment')
    current.domains.create!(:name => 'example.com')

    @request.expects(:host).returns('example.com').at_least_once
    get :index

    assert_equal current, assigns(:environment)
  end


  def test_local_files_reference
    assert_local_files_reference
  end

  def test_valid_xhtml
    assert_valid_xhtml
  end

  def test_exist_environment_variable_to_helper_environment_identification
    get :index
    assert_not_nil assigns(:environment)
  end

  def test_get_against_post_only
    get :post_only
    assert_redirected_to :action => 'index'
  end
  def test_post_against_post_only
    post :post_only
    assert_response :success
    assert_tag :tag => 'span', :content => 'post_only'
  end

  def test_should_generate_help_box_when_passing_string
    get :help_with_string
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => { :tag => 'div', :content => /my_help_message/ }
      }
    })
  end

  def test_should_generate_help_box_when_passing_block
    get :help_with_block
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => { :tag => 'div', :content => /my_help_message/ }
      }
    })
  end

  def test_should_generate_help_box_expanding_textile_markup_when_passing_string
    get :help_textile_with_string
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => {
          :tag => 'strong',
          :content => /my_bold_help_message/
        }
      }
    })
  end

  def test_should_generate_help_box_expanding_textile_markup_when_passing_block
    get :help_textile_with_block
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => {
          :tag => 'strong',
          :content => /my_bold_help_message/
        }
      }
    })
  end

  def test_shouldnt_generate_help_box_markup_when_no_block_is_passed
    get :help_without_block
    assert_no_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
    })
  end

  should 'be able to not use design blocks' do

    class UsesBlocksTestController < ApplicationController
    end
    assert UsesBlocksTestController.new.uses_design_blocks?

    class DoesNotUsesBlocksTestController < ApplicationController
      no_design_blocks
    end
    assert !DoesNotUsesBlocksTestController.new.uses_design_blocks?
  end

  should 'generate blocks' do
    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'boxes', :class => 'boxes' }
  end

  should 'not generate blocks when told not to do so' do
    @controller.stubs(:uses_design_blocks?).returns(false)
    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'boxes', :class => 'boxes'  }
  end

  should 'display only some categories in menu' do
    @controller.stubs(:get_layout).returns('application')
    c1 = Environment.default.categories.create!(:name => 'Category 1', :display_color => 1, :parent => nil, :display_in_menu => true )
    c2 = Environment.default.categories.create!(:name => 'Category 2', :display_color => nil, :parent => c1, :display_in_menu => true )
    get :index
    assert_tag :tag => 'a', :content => /Category 2/
  end

  should 'not display some categories in menu' do
    @controller.stubs(:get_layout).returns('application')
    c1 = Environment.default.categories.create!(:name => 'Category 1', :display_color => 1, :parent_id => nil, :display_in_menu => true)
    c2 = Environment.default.categories.create!(:name => 'Category 2', :display_color => nil, :parent_id => c1)
    get :index
    assert_no_tag :tag => 'a', :content => /Category 2/
  end

  should 'display dropdown for select language' do
    @controller.stubs(:get_layout).returns('application')
    Noosfero.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro', 'fr' => 'Français', 'it' => 'Italiano' }).at_least_once
    get :index, :lang => 'en'
    assert_tag :tag => 'option', :attributes => { :value => 'en', :selected => 'selected' }, :content => 'English'
    assert_no_tag :tag => 'option', :attributes => { :value => 'pt_BR', :selected => 'selected' }, :content => 'Português Brasileiro'
    assert_tag :tag => 'option', :attributes => { :value => 'pt_BR' }, :content => 'Português Brasileiro'
    assert_tag :tag => 'option', :attributes => { :value => 'fr' }, :content => 'Français'
    assert_tag :tag => 'option', :attributes => { :value => 'it' }, :content => 'Italiano'
  end

  should 'display link to webmail if enabled for system' do
    @controller.stubs(:get_layout).returns('application')
    login_as('ze')
    MailConf.expects(:enabled?).returns(true)
    MailConf.expects(:webmail_url).returns('http://web.mail/')

    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'user_box' }, :descendant => { :tag => 'a', :attributes => { :href => 'http://web.mail/' } }
  end

  should 'not display link to webmail if not enabled for system' do
    @controller.stubs(:get_layout).returns('application')
    login_as('ze')
    MailConf.expects(:enabled?).returns(false)

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'user_box' }, :descendant => { :tag => 'a', :attributes => { :href => 'http://web.mail/' } }
  end

  should 'display theme test panel when testing theme' do
    @request.session[:theme] = 'my-test-theme'
    theme = mock
    profile = mock
    theme.expects(:owner).returns(profile).at_least_once
    profile.expects(:identifier).returns('testinguser').at_least_once
    Theme.expects(:find).with('my-test-theme').returns(theme).at_least_once
    get :index

    assert_tag :tag => 'div', :attributes => { :id => 'theme-test-panel' }, :descendant => {
      :tag => 'a', :attributes => { :href => '/myprofile/testinguser/themes/edit/my-test-theme'}
    }
      #{ :tag => 'a', :attributes => { :href => '/myprofile/testinguser/themes/stop_test/my-test-theme'} }
  end

  should 'not display theme test panel in general' do
    @controller.stubs(:session).returns({})
    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'theme-test-panel' }
  end

  should 'load terminology from environment' do
    term = Zen3Terminology.instance
    env = Environment.default
    Environment.stubs(:default).returns(env)
    env.stubs(:terminology).returns(term)
    env.stubs(:id).returns(-9999)

    get :index
    assert_equal Noosfero.terminology, term
  end

  should 'not display categories menu if categories feature disabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(true)
    c1 = Environment.default.categories.create!(:name => 'Category 1', :display_color => 1, :parent => nil, :display_in_menu => true )
    c2 = Environment.default.categories.create!(:name => 'Category 2', :display_color => nil, :parent => c1, :display_in_menu => true )
    get :index
    assert_no_tag :tag => 'a', :content => /Category 2/
  end

  should 'show name of article as title of page' do
    p = create_user('test_user').person
    a = p.articles.create!(:name => 'test article')

    @controller.instance_variable_set('@profile', p)
    @controller.instance_variable_set('@page', a)

    get :index
    assert_tag 'title', :content => 'test article - ' + p.name + ' - ' + p.environment.name
  end

  should 'diplay name of profile in the title' do
    p = create_user('test_user').person
    p.name = 'Some Test User'
    p.save!
    @controller.instance_variable_set('@profile', p)

    get :index, :profile => p.identifier
    assert_tag 'title', :content => p.name + ' - ' + p.environment.name
  end

  should 'display menu links for my environment when logged in other environment' do
    @controller.stubs(:get_layout).returns('application')
    e = fast_create(Environment, :name => 'other_environment')
    e.domains << Domain.new(:name => 'other.environment')
    e.save!

    login_as(create_admin_user(e))
    uses_host 'other.environment'
    get :index
    assert_tag :tag => 'div', :attributes => {:id => 'user_menu_ul'}
    assert_tag :tag => 'div', :attributes => {:id => 'user_menu_ul'},
                :descendant => {:tag => 'a', :attributes => { :href => 'http://other.environment/adminuser' }},
                :descendant => {:tag => 'a', :attributes => { :href => 'http://other.environment/myprofile/adminuser' }},
                :descendant => {:tag => 'a', :attributes => { :href => '/admin' }}
  end

  should 'not display invisible blocks' do
    @controller.expects(:uses_design_blocks?).returns(true)
    p = create_user_full('test_user').person
    @controller.expects(:profile).at_least_once.returns(p)
    b = p.blocks[1]
    b.expects(:visible?).returns(false)
    b.save!

    get :index, :profile => p.identifier

    assert_no_tag :tag => 'div', :attributes => {:id => 'block-' + b.id.to_s}
  end

  should 'diplay name of environment in description' do
    get :index
    assert_tag :tag => 'meta', :attributes => { :name => 'description', :content => assigns(:environment).name }
  end

  should 'set html lang as the article language if an article is present and has a language' do
    a = fast_create(Article, :name => 'test article', :language => 'fr')
    @controller.instance_variable_set('@page', a)
    FastGettext.stubs(:locale).returns('es')
    get :index
    assert_tag :html, :attributes => { :lang => 'fr' }
  end

  should 'set html lang as locale if no page present' do
    FastGettext.stubs(:locale).returns('es')
    get :index
    assert_tag :html, :attributes => { :lang => 'es' }
  end

  should 'set html lang as locale if page has no language' do
    a = fast_create(Article, :name => 'test article', :language => nil)
    @controller.instance_variable_set('@page', a)
    FastGettext.stubs(:locale).returns('es')
    get :index
    assert_tag :html, :attributes => { :lang => 'es' }
  end

  should 'include stylesheets supplied by plugins' do
    class Plugin1 < Noosfero::Plugin
      def stylesheet?
        true
      end
    end
    plugin1_path = '/plugin1/style.css'

    class Plugin2 < Noosfero::Plugin
      def stylesheet?
        true
      end
    end
    plugin2_path = '/plugin2/style.css'

    environment = Environment.default
    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    get :index

    assert_tag :tag => 'link', :attributes => {:href => /#{plugin1_path}/, :type => 'text/css', :rel => 'stylesheet'}
    assert_tag :tag => 'link', :attributes => {:href => /#{plugin2_path}/, :type => 'text/css', :rel => 'stylesheet'}
  end

  should 'include javascripts supplied by plugins' do
    class Plugin1 < Noosfero::Plugin
      def js_files
        ['js1.js']
      end
    end

    js1 = 'js1.js'
    plugin1_path = '/plugin1/'+js1

    class Plugin2 < Noosfero::Plugin
      def js_files
        ['js2.js', 'js3.js']
      end
    end

    js2 = 'js2.js'
    js3 = 'js3.js'
    plugin2_path2 = '/plugin2/'+js2
    plugin2_path3 = '/plugin2/'+js3

    environment = Environment.default
    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    get :index

    assert_tag :tag => 'script', :attributes => {:src => /#{plugin1_path}/, :type => 'text/javascript'}
    assert_tag :tag => 'script', :attributes => {:src => /#{plugin2_path2}/, :type => 'text/javascript'}
    assert_tag :tag => 'script', :attributes => {:src => /#{plugin2_path3}/, :type => 'text/javascript'}
  end

  should 'include content in the beginning of body supplied by plugins regardless it is a block or html code' do
    class TestBodyBeginning1Plugin < Noosfero::Plugin
      def plugin1_method
        '[[plugin1]]'
      end
      def body_beginning
        lambda {"<span id='plugin1'>This is #{plugin1_method} speaking!</span>"}
      end
    end
    class TestBodyBeginning2Plugin < Noosfero::Plugin
      def body_beginning
        "<span id='plugin2'>This is Plugin2 speaking!</span>"
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBodyBeginning1Plugin.new, TestBodyBeginning2Plugin.new])

    get :index

    assert_tag :tag => 'span', :content => 'This is [[plugin1]] speaking!', :attributes => {:id => 'plugin1'}
    assert_tag :tag => 'span', :content => 'This is Plugin2 speaking!', :attributes => {:id => 'plugin2'}
  end

  should 'include content in the ending of head supplied by plugins regardless it is a block or html code' do

    class TestHeadEnding1Plugin < Noosfero::Plugin
      def plugin1_method
        '[[plugin1]]'
      end
      def head_ending
        lambda {"<script>alert('This is #{plugin1_method} speaking!')</script>"}
      end
    end
    class TestHeadEnding2Plugin < Noosfero::Plugin
      def head_ending
        "<style>This is Plugin2 speaking!</style>"
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestHeadEnding1Plugin.new, TestHeadEnding2Plugin.new])

    get :index

    assert_tag :tag => 'script', :content => "alert('This is [[plugin1]] speaking!')"
    assert_tag :tag => 'style', :content => 'This is Plugin2 speaking!'
  end

  if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'

    should 'change postgresql schema' do
      uses_host 'schema1.com'
      Noosfero::MultiTenancy.expects(:on?).returns(true)
      Noosfero::MultiTenancy.expects(:mapping).returns({ 'schema1.com' => 'schema1' })
      exception = assert_raise(ActiveRecord::StatementInvalid) { get :index }
      assert_match /SET search_path TO schema1/, exception.message
    end

    should 'not change postgresql schema if multitenancy is off' do
      uses_host 'schema1.com'
      Noosfero::MultiTenancy.stubs(:on?).returns(false)
      Noosfero::MultiTenancy.stubs(:mapping).returns({ 'schema1.com' => 'schema1' })
      assert_nothing_raised(ActiveRecord::StatementInvalid) { get :index }
    end

  end
end
