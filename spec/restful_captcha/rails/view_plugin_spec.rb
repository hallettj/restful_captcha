require File.expand_path(File.dirname(__FILE__) + '/../rails_spec_helper')

describe ViewPlugin do

  class ViewClass < ActionView::Base
  end

  before :each do
    @view = ViewClass.new
  end

  before :each do
    @captcha = mock(Captcha, :image_url => 'http://images.com/beetle.jpg')
  end

  it "should display a different captcha every time" do
    @view.should_receive(:reset_captcha)
    @view.should_receive(:captcha).and_return(@captcha)
    @view.captcha_tag
  end

  it "should display the image for the recorded captcha" do
    @view.should_receive(:reset_captcha)
    @view.should_receive(:captcha).and_return(@captcha)
    @view.should_receive(:image_tag).with(@captcha.image_url, { :alt => 'captcha image' })
    @view.captcha_tag
  end

  it "should accept options and pass them on as image attributes" do
    @view.should_receive(:reset_captcha)
    @view.should_receive(:captcha).and_return(@captcha)
    @view.should_receive(:image_tag).with(@captcha.image_url, { :alt => 'a beetle captcha' })
    @view.captcha_tag(:alt => 'a beetle captcha')
  end

  it "should render a default alt text value" do
    @view.should_receive(:reset_captcha)
    @view.should_receive(:captcha).and_return(@captcha)
    @view.should_receive(:image_tag).with(@captcha.image_url, { :alt => 'captcha image' })
    @view.captcha_tag
  end

  it "should allow the default alt text value to be overwritten" do
    @view.should_receive(:reset_captcha)
    @view.should_receive(:captcha).and_return(@captcha)
    @view.should_receive(:image_tag).with(@captcha.image_url, { :alt => 'a beetle captcha' })
    @view.captcha_tag(:alt => 'a beetle captcha')
  end
  
end
