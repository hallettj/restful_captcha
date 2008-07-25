require File.expand_path(File.dirname(__FILE__) + '/../rails_spec_helper')

describe ControllerPlugin do

  class ControllerClass < ActionController::Base
  end

  before :each do
    @session = {}
    @controller = ControllerClass.new
    @controller.stub!(:session).and_return(@session)
  end

  it "should make the captcha accessor and resetter methods available to template code" do
    class SomeClass; end
    SomeClass.should_receive(:helper_method).with(:captcha, :reset_captcha)
    class SomeClass
      include RestfulCaptcha::Rails::ControllerPlugin
    end
  end

  it "should install a method to set the captcha host" do
    ControllerClass.should respond_to(:set_captcha_host)
    ControllerClass.set_captcha_host('testhost.tv')
    Captcha.host.should == 'testhost.tv'
  end

  it "should fetch a CAPTCHA" do
    pending
    @controller.reset_captcha
    @session[:captcha].should_not be_nil
  end

end
