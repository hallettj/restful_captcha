require File.expand_path(File.dirname(__FILE__) + '/../../lib/restful_captcha/plugin')

describe RestfulCaptcha::Plugin do

  class ControllerClass
    def self.helper_method(methods)
    end
    include RestfulCaptcha::Plugin
  end

  before :each do
    @session = {}
    @controller = ControllerClass.new
    @controller.stub!(:session).and_return(@session)
  end

  it "should make the CAPTCHA image URL helper available to template code" do
    class SomeClass; end
    SomeClass.should_receive(:helper_method).with(:captcha_image_url)
    class SomeClass
      include RestfulCaptcha::Plugin
    end
  end

  it "should fetch a CAPTCHA" do
    @controller.reset_captcha
    @session[:captcha].should_not be_nil
  end



end
