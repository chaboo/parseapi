require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "ParseApplications basic operations" do
    
    it "retrieves ParseApplication configuration" do
      object = FactoryGirl.create(:parse_application, config: {"welcomeMessage"=> "Welcome to The Internet!",  "winningNumber"=> 42})

      get api(config_path)
      expect(response).to be_success
      expect(json_response['params']).to eq(object.config)
    end

    it "retrieves {} if ParseApplication configuration is nil" do
      FactoryGirl.create(:parse_application)

      get api(config_path)
      expect(response).to be_success
      expect(json_response['params']).to eq({})
    end
  end
end