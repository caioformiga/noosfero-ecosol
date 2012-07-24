require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../app/controllers/public/account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase

  SALT=YAML::load(File.open(StoaPlugin.root_path + '/config.yml'))['salt']

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @db = Tempfile.new('stoa-test')
    configs = ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => @db.path}
    ActiveRecord::Base.establish_connection(:stoa)
    ActiveRecord::Schema.verbose = false
    ActiveRecord::Schema.create_table "pessoa" do |t|
      t.integer  "codpes"
      t.text     "numcpf"
      t.date     "dtanas"
    end
    ActiveRecord::Base.establish_connection(:test)
    StoaPlugin::UspUser.create!(:codpes => 12345678, :cpf => Digest::MD5.hexdigest(SALT+'12345678'), :birth_date => '1970-01-30')
    Environment.default.enable_plugin(StoaPlugin.name)
  end

  def teardown
    @db.unlink
  end

  should 'fail if confirmation value doesn\'t match' do
    #StoaPlugin::UspUser.stubs(:matches?).returns(false)
    post :signup, :profile_data => {:usp_id => '12345678'}, :confirmation_field => 'cpf', :cpf => '00000000'
    assert_not_nil assigns(:person).errors[:usp_id]
  end

  should 'pass if confirmation value matches' do
    #StoaPlugin::UspUser.stubs(:matches?).returns(true)
    post :signup, :profile_data => {:usp_id => '12345678'}, :confirmation_field => 'cpf', :cpf => '12345678'
    assert_nil assigns(:person).errors[:usp_id]
  end

  should 'inlude invitation_code param in the person\'s attributes' do
    get :signup, :invitation_code => 12345678
    assert assigns(:person).invitation_code == '12345678'
  end

end
