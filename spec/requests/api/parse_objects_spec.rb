require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "Basic operations" do
    it "should create new ParseObject with provided class_name" do
      headers = { content_type: 'application/json' }
      properties = {foo: "bar", boolean: true}
      expect { post api(objects_path("Game")), properties.to_json, headers }.to change {ParseObject.count}.by(1)
    end

    it "retrieves specific ParseObject with provided class_name" do
      object = FactoryGirl.create(:parse_object)
      get api(objects_path(object))

      expect(response).to be_success
      expect(json_response['score']).to eq(object.properties["score"])
    end

    it "should update specific ParseObject" do
      headers = { content_type: 'application/json' }
      object = FactoryGirl.create(:parse_object)
      score = "10000"
      put api(objects_path(object)), {score: score}.to_json, headers
      expect(response).to be_success

      get api(objects_path(object))
      expect(response).to be_success
      expect(json_response['score']).to eq(score)
    end

    it "should delete specific ParseObject" do
      object = FactoryGirl.create(:parse_object)
      expect { delete api(objects_path(object)) }.to change {ParseObject.count}.by(-1)
      expect(response).to be_success
    end
  end

  describe "Batch operations" do
    it "should create multiple objects in single request" do
      headers = { content_type: 'application/json' }
      json = '{"requests": [
        {"method":"POST","path":"/1/classes/GameScore", "body":{"score":"3","playerName":"Ferrer"}},
        {"method":"POST","path":"/1/classes/GameScore", "body":{"score":"1","playerName":"Safin"}}
      ]}'

      expect { post api(batch_path), json, headers }.to change {ParseObject.count}.by(2)
    end

    it "should process update and delete operations in single batch request" do
      object1 = FactoryGirl.create(:parse_object, properties: {score: 1000})
      object2 = FactoryGirl.create(:parse_object, properties: {score: 2000})

      headers = { content_type: 'application/json' }
      batch_request = {requests: [
        { method: "PUT", path: api(objects_path(object1)), body: { score: 10000 } },
        { method: "DELETE", path: api(objects_path(object2)) }
      ]}
      
      expect { post api(batch_path), batch_request.to_json, headers }.to change {ParseObject.count}.by(-1)
      expect(response).to be_success
      expect(json_response.size).to eq(2)
      expect(json_response.first["success"]["updatedAt"]).to_not eq(nil)
    end

    it "should return error in case of unsupported operation" do

    end
  end
end