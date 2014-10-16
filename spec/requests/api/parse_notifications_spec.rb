require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "ParseNotifications" do
    describe "success scenarios" do
      it "should send notifications to installations subscribed to specific channel" do
        installation1 = FactoryGirl.create(:parse_installation, channels: ["cha1", "cha2"])
        installation2 = FactoryGirl.create(:parse_installation, channels: ["cha3", "cha4"])
        
        headers = { CONTENT_TYPE: 'application/json' }
        req = { 
                channels: ["cha3"],
                data: { alert: "Some alert message"}
              }
        
        post api(notifications_path), req.to_json, headers
        
        expect(response.status).to eq(200)
        expect(json_response['result']).to eq(true)
        expect(json_response['recipients']).to eq([installation2.id])
      end

      # it "should send notifications to installations which satisfy the query" do
      #   headers = { CONTENT_TYPE: 'application/json' }
      #   req = { 
      #           where: { injuryReports: true },
      #           data: { alert: "Some alert message"}
      #         }
        
      #   post api(notifications_path), req.to_json, headers
        
      #   expect(response.status).to eq(200)
      #   expect(json_response['result']).to eq(true)
      # end

      it "should send notifications to installations which satisfy the complex query with single channel" do
        installation1 = FactoryGirl.create(:parse_installation, channels: ["cha1"])
        installation2 = FactoryGirl.create(:parse_installation, channels: ["cha2"])
        installation3 = FactoryGirl.create(:parse_installation, channels: ["cha3"])
      
        headers = { CONTENT_TYPE: 'application/json' }
        req = {
                where: {
                  # injuryReports: true,
                  channels: "cha2"
                },
                data: { alert: "Some alert message"}
              }

        post api(notifications_path), req.to_json, headers

        expect(response.status).to eq(200)
        expect(json_response['result']).to eq(true)
        expect(json_response['recipients']).to eq([installation2.id])
      end

      it "should send notifications to installations which satisfy the complex query with multiple channels" do
        installation1 = FactoryGirl.create(:parse_installation, channels: ["cha1"])
        installation2 = FactoryGirl.create(:parse_installation, channels: ["cha2"])
        installation3 = FactoryGirl.create(:parse_installation, channels: ["cha3"])
      
        headers = { CONTENT_TYPE: 'application/json' }
        req = {
                where: { 
                  # injuryReports: true,
                  channels: ["cha1", "cha3"]
                },
                data: { alert: "Some alert message"}
              }

        post api(notifications_path), req.to_json, headers

        expect(response.status).to eq(200)
        expect(json_response['result']).to eq(true)
        expect(json_response['recipients']).to match_array([installation1.id, installation3.id])
      end

    end

    describe "failure scenarios" do
      it "should fail due to missing push channels" do
        headers = { CONTENT_TYPE: 'application/json' }
        req = { data: { alert: "Some alert message"} }

        post api(notifications_path), req.to_json, headers

        expect(response.status).to eq(400)
        expect(json_response['code']).to eq(115)
        expect(json_response['error']).to eq("Missing the push channels.")
      end

      it "should fail due to presence of both channels and where clause" do
        headers = { CONTENT_TYPE: 'application/json' }
        req = {
                where: {
                  injuryReports: true,
                },
                channels: ["test1"],
                data: {
                  alert: "Some alert message"
                }
              }

        post api(notifications_path), req.to_json, headers

        expect(response.status).to eq(400)
        expect(json_response['code']).to eq(117)
        expect(json_response['error']).to eq("Can't set channels for a query-targeted push.")
      end

      it "should fail since channels is not an array" do
        headers = { CONTENT_TYPE: 'application/json' }
        channel_name = "test1"
        req = {
                channels: channel_name,
                data: {
                  alert: "Some alert message"
                }
              }

        post api(notifications_path), req.to_json, headers

        expect(response.status).to eq(400)
        expect(json_response['code']).to eq(107)
        expect(json_response['error']).to eq("Invalid json: " + channel_name)
      end

      it "should fail since data is not present" do
        headers = { CONTENT_TYPE: 'application/json' }
        channel_name = ["test"]
        req = { channels: channel_name }

        post api(notifications_path), req.to_json, headers

        expect(response.status).to eq(400)
        expect(json_response['code']).to eq(115)
        expect(json_response['error']).to eq("Missing the push data.")
      end
    end
  end
end