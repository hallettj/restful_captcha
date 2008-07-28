require File.expand_path(File.dirname(__FILE__) + '/../rails_spec_helper')

describe ControllerPlugin do

  class ControllerClass < ActionController::Base
    public :captcha, :reset_captcha, :unset_captcha
#    set_captcha_style(:color => 'red', :background_color => 'blue', :font_weight => 'bold')
    def captcha_params; @@captcha_params; end
  end

  before :each do
    @session = {}
    @controller = ControllerClass.new
    @controller.stub!(:session).and_return(@session)
  end

  before :each do
    @captcha = mock(Captcha, :identifier => '789cd3d5d555e04a4a4cce4e2fca2fcd4b894fcecfc92fb25248ca294de52a49ad28b15228f328adcae1828a17a5a670a5e5e795c497a766a667006593f27352b818100000417717ff')
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

  it "should install a method to set the captcha style" do
    ControllerClass.should respond_to(:set_captcha_style)
    ControllerClass.set_captcha_style(:color => 'red', :font_family => 'trebuchet')
    @controller.captcha_params.should == { :color => 'red', :font_family => 'trebuchet' }
  end

  it "should inherit captcha styles from parent classes, cascading style" do
    ControllerClass.set_captcha_style(:color => 'red', :font_family => 'trebuchet')
    class SubControllerClass < ControllerClass
      set_captcha_style(:color => 'green')
    end
    subcontroller = SubControllerClass.new
    subcontroller.captcha_params.should == { :color => 'green', :font_family => 'trebuchet' }
  end

  describe "before a captcha has been recorded in the session data" do

    before :each do
      Captcha.stub!(:find_by_identifier).and_return(nil)
    end

    it "should not find a recorded captcha" do
      @controller.captcha.should be_nil
    end

    it "should be able to set a captcha" do
      Captcha.should_receive(:find_by_attributes).and_return(@captcha)
      @controller.reset_captcha.should == @captcha
      @controller.session[:captcha].should == @captcha.identifier
    end

  end

  describe "after a captcha is set" do

    before :each do
      @controller.session[:captcha] = @captcha.identifier
      @other_captcha = mock(Captcha, :identifier => '23957925729587')
    end

    it "should be able to retrieve the captcha from session data" do
      Captcha.should_receive(:find_by_identifier).with(@captcha.identifier).and_return(@captcha)
      @controller.captcha.should == @captcha
    end

    it "should be able to replace the captcha with a new one" do
      Captcha.should_receive(:find_by_attributes).and_return(@other_captcha)
      Captcha.should_receive(:find_by_identifier).with(@captcha.identifier).and_return(@captcha)
      Captcha.stub!(:find_by_identifier).with(@other_captcha.identifier).and_return(@other_captcha)
      @controller.captcha.should == @captcha
      @controller.reset_captcha.should == @other_captcha
      @controller.captcha.should == @other_captcha
    end

    it "should be able to unset the captcha" do
      Captcha.should_receive(:find_by_identifier).with(@captcha.identifier).and_return(@captcha)
      Captcha.stub!(:find_by_identifier).with(nil).and_return(nil)
      @controller.captcha.should == @captcha
      @controller.unset_captcha
      @controller.captcha.should be_nil
    end

  end

  it "should use user specified parameters when finding a new captcha to set" do
    Captcha.should_receive(:find_by_attributes).with(@controller.captcha_params).and_return(@captcha)
    @controller.reset_captcha
  end
  
end
