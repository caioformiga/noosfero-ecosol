class DistributionPluginDeliveryOptionController < DistributionPluginMyprofileController

  no_design_blocks

  before_filter :load

  def select
    @session = DistributionPluginSession.find params[:session_id]
    render :layout => false
  end

  def index
    @session = DistributionPluginSession.find params[:session_id]
  end

  def show
    @delivery_option = DistributionPluginSession.find params[:id]
  end

  def new
    @session = DistributionPluginSession.find params[:session_id]
    @session.add_delivery_options = params[:session][:add_delivery_options]
    @session.save(false) # skip validations as needed for a new session
  end

  def destroy
    @delivery_option = @node.delivery_options.find params[:id]
    @session = @delivery_option.session
    @delivery_option.destroy
  end

  def method_destroy
    @session = DistributionPluginSession.find params[:session_id]
    @delivery_method = @node.delivery_methods.find_by_id params[:id]
    @delivery_method.destroy
  end

  def method_new
    @session = DistributionPluginSession.find params[:session_id]
    @delivery_method = DistributionPluginDeliveryMethod.create! params[:delivery_method].merge(:node => @node, :delivery_type => 'pickup')
  end

  def method_edit
    @session = DistributionPluginSession.find params[:session_id]
    @delivery_method = @node.delivery_methods.find_by_id params[:id]
    if request.post?
      @delivery_method.update_attributes! params[:delivery_method].merge(:node => @node, :delivery_type => 'pickup')
      @delivery_method = DistributionPluginDeliveryMethod.new # reset form for a new method
    end
  end

  protected

  def load
    @delivery_methods = @node.delivery_methods
    @delivery_method = DistributionPluginDeliveryMethod.new
  end

end
