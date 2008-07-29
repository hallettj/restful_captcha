require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'RestfulCaptcha' do

  before :all do
    request = mock("request")
    response = mock("response", :body= => nil)
    route_params = mock("route_params")
    @context = Sinatra::EventContext.new(request, response, route_params)
  end

  before :all do
    @example = RestfulCaptcha::Captcha.new(:text => "foo", :secret => "wibble")
  end
  
  describe "when a new CAPTCHA is requested by parameters" do

    def reconstructed_captcha(response=@response)
      RestfulCaptcha::Captcha.find(response.body)
    end

    it "should respond with a CAPTCHA identifier" do
      get_it '/captcha'
      @response.status.should == 200
      @response.body.should_not be_empty
    end

    it "should respond with an identifier that can be used to reconstruct a CAPTCHA" do
      get_it '/captcha?text=foobarnao&secret=wibble'
      captcha = reconstructed_captcha
      captcha[:text].should == 'foobarnao'
      captcha[:secret].should == 'wibble'
    end

    it "should accept text for the CAPTCHA" do
      get_it '/captcha?text=foo'
      reconstructed_captcha[:text].should == 'foo'
    end

    it "should accept a secret to hide in the CAPTCHA" do
      get_it '/captcha?secret=wibble'
      reconstructed_captcha[:secret].should == 'wibble'
    end

    it "should accept color parameters" do
      get_it '/captcha?color=blue&background_color=red'
      captcha = reconstructed_captcha
      captcha[:color].should == 'blue'
      captcha[:background_color].should == 'red'
    end

    it "should accept background texture parameters" do
      get_it '/captcha?background=granite'
      reconstructed_captcha[:background].should == 'granite'
    end

    it "should accept font parameters" do
      get_it '/captcha?font_family=arial&font_weight=bold&font_style=italics&font_size=100'
      captcha = reconstructed_captcha
      captcha[:font_family].should == 'arial'
      captcha[:font_weight].should == 'bold'
      captcha[:font_style].should == 'italics'
      captcha[:font_size].should == '100'
    end

    it "should accept font parameters in the form of a fully qualified X font name" do
      get_it '/captcha?font=-urw-times-medium-i-normal--0-0-0-0-p-0-iso8859-13'
      reconstructed_captcha[:font].should == '-urw-times-medium-i-normal--0-0-0-0-p-0-iso8859-13'
    end

  end

  describe "when a CAPTCHA is requested by identifer" do

    it "should respond with the same identifier if the CAPTCHA exists" do
      get_it "/captcha/#{@example.identifier}"
      @response.status.should == 200
      @response.body.should == @example.identifier
    end

    it "should respond with a 'resource not found' error if the CAPTCHA does not exist" do
      get_it "/captcha/2985729387239487"
      @response.status.should == 404
    end

  end

  describe "when an image is requested" do

    it "should require an identifier" do
      get_it 'http://image/'
      @response.status.should == 404
    end

    it "should respond with an image" do
      get_it "/captcha/#{@example.identifier}/image"
      @response.status.should == 200
      @response.headers['Content-Type'].should == 'image/png'
      @response.headers['Content-Transfer-Encoding'].should == 'binary'
      @response.body.should_not be_empty
    end

    it "should respond with an error if the captcha can't be found" do
      get_it "/captcha/bad_identifier/image"
      @response.status.should == 404
    end

    it "should preserve parameters encoded in the CAPTCHA identifier" do
      pending "figure out how to read captcha attributes"
      get_it "/image/#{@example.identifier}"
      captcha = assigns[:captcha]
      captcha.should_not be_nil
    end

    it "should respond with a 'resource not found' error if the captcha can't be found" do
      get_it 'http://image/475447486856476325241'
      @response.status.should == 404
    end

  end

  describe "when answer validity is requested" do

    describe "if the answer is correct" do

      before :each do
        get_it "/captcha/#{@example.identifier}/#{@example[:text]}"
        @yaml_response = YAML::load(@response.body)
      end
      
      it "should respond with a YAML file" do
        lambda { YAML::load(@response.body) }.should_not raise_error
      end

      it "should indicate that the answer is correct" do
        @yaml_response["correct"].should be_true
      end

      it "should include the hidden answer in the response" do
        @yaml_response["secret"].should == @example[:secret]
      end

    end

    describe "if the answer is incorrect" do

      before :each do
        get_it "/captcha/#{@example.identifier}/incorrect-answer"
        @yaml_response = YAML::load(@response.body)
      end

      it "should respond with a YAML file" do
        lambda { YAML::load(@response.body) }.should_not raise_error
      end

      it "should indicate that the answer is incorrect" do
        @yaml_response["correct"].should be_false
      end

      it "should not include any hidden secret in the response" do
        @yaml_response["secret"].should be_nil
      end

    end

    it "should consider an answer to be correct if it differs in case from the CAPTCHA text" do
      get_it "/captcha/#{@example.identifier}/#{@example[:text].upcase}"
      YAML::load(@response.body)['correct'].should be_true
    end

    it "should include the CAPTCHA identifier in the response" do
      get_it "/captcha/#{@example.identifier}/#{@example[:text].upcase}"
      YAML::load(@response.body)['identifier'].should == @example.identifier
    end

    it "should include the given answer in the response" do
      get_it "/captcha/#{@example.identifier}/#{@example[:text].upcase}"
      YAML::load(@response.body)['answer'].should == @example[:text].upcase
    end

    it "should respond with a 'resource not found' error if the captcha can't be found" do
      get_it '/captcha/547574599891223/foo'
      @response.status.should == 404
    end

  end

end
