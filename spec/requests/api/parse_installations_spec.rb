require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "ParseInstallations" do
    
    it "should create a new installation" do
      headers = { "CONTENT_TYPE" => "application/json" }
      req = { 
              deviceType:   "ios", 
              deviceToken:  "token1", 
              channels:     ["channel1","channel2"]
            }

      expect{ post api(installations_path), req.to_json, headers }.to change {ParseInstallation.count}.by(1)
      expect(response).to be_success
      expect(json_response["createdAt"]).to_not eq(nil)
      expect(json_response["objectId"]).to_not eq(nil)
      expect(response.header["Location"]).to eq("http://localhost:3000/1/installations/#{json_response["objectId"]}")
    end

    it "should retrieve specific installation" do
      installation = FactoryGirl.create(:parse_installation)
      get api(installations_path(installation))

      expect(response).to be_success
      expect(json_response['deviceToken']).to eq(installation.device_token)
      expect(json_response['deviceType']).to eq(installation.device_type)
      expect(json_response['channels']).to eq(installation.channels)
    end

    it "should delete an installation" do
      installation = FactoryGirl.create(:parse_installation)
      expect{ delete api(installations_path(installation)) }.to change{ ParseInstallation.count }.by(-1)
      expect(response).to be_success
    end

    it "should update an installation (subscribe to channels)" do
      headers = { content_type: 'application/json' }
      installation = FactoryGirl.create(:parse_installation)
      test_device_token = "123131313131"
      test_channels = ["test"]

      put api(installations_path(installation)), {device_token: test_device_token, channels: test_channels}.to_json, headers
      expect(response).to be_success

      get api(installations_path(installation))
      expect(response).to be_success
      expect(json_response['deviceToken']).to eq(test_device_token)
      expect(json_response['channels']).to eq(test_channels)
    end

    it "should retrieve all ParseInstallation objects" do
      FactoryGirl.create_list(:parse_installation, 3)
      get api(installations_path)
      expect(response).to be_success
      expect(json_response['results'].size).to eq(3)
    end
  end
end