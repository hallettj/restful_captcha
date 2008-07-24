require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RestfulCaptcha::Captcha do
  
  describe "when creating a new CAPTCHA" do

    it "should build a CAPTCHA as defined by given parameters" do
      captcha = RestfulCaptcha::Captcha.new(:text => "foo", :secret => "wibble")
      captcha[:text].should == "foo"
      captcha[:secret].should == "wibble"
    end

    it "should silently reject parameters that are not recognized by RestfulCaptcha::Image" do
      captcha = RestfulCaptcha::Captcha.new(:answer => "not-foo", :font_family => "arial")
      captcha[:answer].should be_nil
      captcha[:font_family].should == "arial"
    end

    it "should accept 'secret' as a parameter" do
      captcha = RestfulCaptcha::Captcha.new(:text => "foo", :secret => "wibble")
      captcha[:secret].should == "wibble"
    end

    it "should convert parameter keys to symbols" do
      captcha = RestfulCaptcha::Captcha.new("text" => "foo", "font_family" => "arial")
      captcha[:text].should == "foo"
    end
    
    it "should set random text if no text is specified" do
      captcha = RestfulCaptcha::Captcha.new
      captcha[:text].should_not be_blank
    end

  end

  before :each do
    @captcha = RestfulCaptcha::Captcha.new(:text => "foo", :secret => "wibble")
  end

  it "should have a unique identifier" do
    @captcha.identifier.should_not be_nil
  end

  it "should not place any characters in identifiers that might confuse routing" do
    (@captcha.identifier =~ /^#{Sinatra::Event::URI_CHAR}+$/).should_not be_nil
  end

  it "should be able to reconstruct a CAPTCHA from its identifier" do
    reconstructed = RestfulCaptcha::Captcha.find(@captcha.identifier)
    reconstructed[:text].should == @captcha[:text]
    reconstructed[:secret].should == @captcha[:secret]
  end

  it "should not be sensitive to case in identifiers" do
    reconstructed = RestfulCaptcha::Captcha.find(@captcha.identifier.upcase)
    reconstructed.should == @captcha
    reconstructed = RestfulCaptcha::Captcha.find(@captcha.identifier.downcase)
    reconstructed.should == @captcha
  end

  it "should return nil if there is a problem interpreting an identifier" do
    RestfulCaptcha::Captcha.find('457474574625231').should be_nil
  end

  it "should be displayable as an image" do
    RestfulCaptcha::Image.should_receive(:build).with(:text => "foo")
    @captcha.image
  end

  it "should verify a correct answer" do
    @captcha.correct_answer?(@captcha[:text]).should be_true
  end

  it "should reject an incorrect answer" do
    @captcha.correct_answer?('incorrect_answer').should_not be_true
  end

  it "should not consider case when checking an answer, unless instructed otherwise" do
    @captcha.correct_answer?(@captcha[:text].upcase).should be_true
  end

  it "should consider case when checking an answer if asked to" do
    @captcha.correct_answer?(@captcha[:text].upcase, true).should be_false
  end

  it "should publically expose its attributes" do
    @captcha[:text].should == "foo"
  end

  it "should expose public setters for its attributes" do
    @captcha[:font_weight] = "bold"
    @captcha[:font_weight].should == "bold"
  end

  it "should reject with an error attribute values that are not recognized by RestfulCaptcha::Image" do
    lambda { @captcha[:awesomeness] = 'a lot' }.should raise_error(ArgumentError)
  end

end
