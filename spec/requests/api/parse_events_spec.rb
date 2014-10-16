require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "ParseEvents" do
    describe "success scenarios" do
      it "should create a new custom event" do
        headers = { CONTENT_TYPE: 'application/json' }
        req = { 
          "dimensions" => { "priceRange" => "1000"},
          "at" => { "__type"  => "Date",  "iso"  => "2014-09-17T23:26:37-07:00" }
        }
        eventname = "CustomEvent"
        
        expect { post api(events_path(eventname)), req.to_json, headers }.to change {ParseEvent.count}.by(1)
        expect(response.body).to eq("{}")
      end
    end

    describe "failure scenarios" do
      it "should fail due to missing push channels" do
        headers = { CONTENT_TYPE: 'application/json' }
        
        post api(events_path("AppOpened")), nil, headers
        
        expect(response.status).to eq(400)
        expect(json_response['code']).to eq(107)
        expect(json_response['error']).to eq("invalid JSON")
      end
    end
  end
end