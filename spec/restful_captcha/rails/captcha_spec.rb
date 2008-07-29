require File.expand_path(File.dirname(__FILE__) + '/../rails_spec_helper')

describe Captcha do
  
  before :each do
    Captcha.host = 'captcha.localhost'
  end

  before :each do
    @captcha = Captcha.find_by_attributes(:text => 'foo',
                                          :color => 'darkblue', 
                                          :background_color => 'yellow')
  end

  it "should have a unique identifier" do
    @captcha.identifier.should_not be_nil
  end
  
  it "should raise an error if no RestfulCaptcha host is specified" do
    Captcha.host = nil
    lambda { Captcha.find_by_attributes }.should raise_error
  end

  describe "when asked to find a captcha given its attributes" do

    before :all do
      @attrs = { :color => 'darkblue', :background_color => 'yellow' }
    end

    it "should instantiate a captcha with the specified attributes" do
      captcha = Captcha.find_by_attributes(@attrs)
      captcha.should be_an_instance_of(Captcha)
      captcha.identifier.should_not be_nil
    end

    it "should instantiate any old captcha if no attributes are specified" do
      captcha = Captcha.find_by_attributes
      captcha.should be_an_instance_of(Captcha)
      captcha.identifier.should_not be_nil
    end

    it "should return nil if there is an error communicating with the server" do
      Captcha.host = 'localhost'
      Captcha.find_by_attributes.should be_nil
    end

  end

  describe "when finding a captcha by its identifier" do
    
    before :each do
      @identifier = @captcha.identifier
    end

    it "should instantiate the appropriate captcha" do
      Captcha.find_by_identifier(@identifier).should be_an_instance_of(Captcha)
    end

    it "should return nil if the identifier doesn't match an existing captcha" do
      Captcha.find_by_identifier('2589234983741984279').should be_nil
    end

  end

  it "should have an image_url" do
    @captcha.image_url.should == "http://captcha.localhost/captcha/#{@captcha.identifier}/image"
  end

  it "should have a remote image at its image_url" do
    url = URI.parse(@captcha.image_url)
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.get(url.path)
    end
    res.should be_a_kind_of(Net::HTTPSuccess)
    res.content_type.should == "image/png"
    res.body.should_not be_nil
  end

  it "should accept an answer" do
    @captcha.answer = "foo"
    @captcha.answer.should == "foo"
  end

  it "should have a shortcut for setting and checking the answer" do
    @captcha.correct_answer?("foo").should be_true
    @captcha.correct_answer?("bar").should be_false
  end

  describe "given a correct answer" do

    before :each do
      @captcha.answer = "foo"
    end

    it "should indicate that the answer is correct" do
      @captcha.should be_answered_correctly
    end

    it "should switch its decision when a new answer is presented" do
      @captcha.answer = "bar"
      @captcha.should_not be_answered_correctly
    end

  end

  describe "given an incorrect answer" do

    before :each do
      @captcha.answer = "bar"
    end

    it "should indicate that the answer is not correct" do
      @captcha.should_not be_answered_correctly
    end

    it "should switch its decision when a new answer is presented" do
      @captcha.answer = "foo"
      @captcha.should be_answered_correctly
    end

  end

end
