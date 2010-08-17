ROOT = File.dirname(__FILE__) + '/..'

require ROOT + '/controller'
require 'rack/test'
require 'webrat'
require 'spec/test/unit'

include Rack::Test::Methods
include Webrat::Methods
include Webrat::Matchers

Webrat.configure do |config|
  config.mode = :rack
end

ENV['RACK_ENV'] = 'test'

describe "Controller" do

  def app
    Sinatra::Application.new
  end

  it "should render main page" do
    visit "/"
    last_response.ok?.should be_true
  end

  describe "main page" do
    it "should contain instructions" do
      visit "/"
      assert_contain "This application"
    end

    it "should generate merged translation file" do
      visit "/"
      attach_file 'Dictionary', ROOT + '/spec/dictionary.xml'
      attach_file 'To translate', ROOT + '/spec/to_translate.xml'
      click_button 'Process'

      last_response.ok?.should be_true
      last_response.body.should == File.read(ROOT + '/spec/output.xml')
    end
  end

end
