require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'core_extensions' do

  it "should define an Enumerable method called collect_with_index" do
    Array.new.should respond_to(:collect_with_index)
  end

  it "should define map_with_index to be an alias of collect_with_index" do
    Array.new.should respond_to(:map_with_index)
  end

  it "should return a new version of an Enumerable with each element modified by a block that accepts the index of the element" do
    [1,1,1,1].collect_with_index { |e,i| e + i }.should == [1,2,3,4]
    [1,1,1,1].map_with_index { |e,i| e + i }.should == [1,2,3,4]
  end
  
end
