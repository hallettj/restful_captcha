require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RestfulCaptcha::Image do
  
  it "should generate an image" do
    RestfulCaptcha::Image.build(:text => "foo").should_not be_nil
  end

  it "should raise an error if no text is given" do
    lambda { RestfulCaptcha::Image.build(:color => "red") }.should raise_error(ArgumentError)
  end

end
