require File.expand_path( '../../spec_helper', __FILE__ )
require 'lash/bundle_helper'


class BH 
  include Lash::BundleHelper
  
  attr_accessor :params
  attr_accessor :cookies
  def initialize 
    @params = {}
    @cookies = {}
  end
end

class String
  def html_safe
    self
  end
end


describe Lash::BundleHelper do

  before :each do
    @fake = BH.new
  end

  context "bundle_files?" do
    context "in development" do
      before :each do
        Rails.env = :development
      end
      
      it "should be false" do
        @fake.bundle_files?.should == false
      end

      it "should be true if params includes bundle=yes" do 
        @fake.params[:bundle] = "yes"
        @fake.bundle_files?.should == true
      end

    end

    context "in production" do
      before :each do
        Rails.env = :production
      end
      
      it "should be true" do
        @fake.bundle_files?.should == true
      end

      it "should be false if params includes bundle=no in production" do
        @fake.params[:bundle] = "no"
        @fake.bundle_files?.should == false
      end
      
    end
    
  end
  
  
  context "javascript_bundle" do 
    
    before :each do
      @fake.stub( :javascript_src_tag ).and_return {|f| "%#{f}%" }
    end
    
    
    context "when bundle_files? is true" do
      before :each do
        Rails.env = :production
      end

      it "should return bundle_application.js" do
        script = @fake.javascript_bundle( "application" )
        script.should =~ /%bundle_application.js%/
      end
    end
    
    context "when _bundle_files? is false" do
      before :each do
        Rails.env = :development
      end
      
      it "should return application, application2 and validate scripts" do
        script = @fake.javascript_bundle( "application" )
        %w{ application application2 tools/validate }.each do |s|
          script.should =~ /%application\/#{s}.js%/        
        end
      end
      
    end
  end

end