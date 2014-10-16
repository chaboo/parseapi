require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "ParseRoles" do
    describe "roles" do
      it "should create a new role" do
        headers = { "CONTENT_TYPE" => 'application/json' }
        content = {
          "name" => "Moderators",
          "ACL" => { "*" => { "read" => true } }
        }
        expect { post api(roles_path), content.to_json, headers }.to change {ParseRole.count}.by(1)

        expect(response.status).to eq(201)
        expect(response.header["Location"]).to eq("http://localhost:3000/1/roles/#{json_response["objectId"]}")
        expect(json_response["objectId"]).not_to eq(nil)
        expect(json_response["createdAt"]).not_to eq(nil)
      end

      it "should retrieve specific role" do
        role = FactoryGirl.create(:parse_role, :properties => {:name => "Moderator", :ACL => {"*" => {"write" => true}}} )
        get api(roles_path(role))
        expect(response).to be_success
        
        expect(json_response["name"]).to eq(role.properties["name"])
        expect(json_response["ACL"]).to eq(role.properties["ACL"])
        # expect(json_response["createdAt"]).to eq(role.created_at.iso8601)
        # expect(json_response["updatedAt"]).to eq(role.updated_at.iso8601)
        expect(json_response["objectId"]).to eq(role.obj_id)
      end

      it "should update specific role" do
        role = FactoryGirl.create(:parse_role)
        previous_updated_at = role.updated_at

        headers = { "CONTENT_TYPE" => "application/json"}
        update_content = 
        {
          "users" => {
            "__op" => "AddRelation",
            "objects" => [
              {
                "__type" => "Pointer",
                "className" => "_User",
                "objectId" => "8TOXdXf3tz"
              },
              {
                "__type" => "Pointer",
                "className" => "_User",
                "objectId" => "g7y9tkhB7O"
              }
            ]
          }
        }

        put api(roles_path(role)), update_content.to_json, headers
        expect(response).to be_success
        # TODO: Time zone and format issues
        expect(json_response["updatedAt"]).not_to eq(previous_updated_at)

        role.reload
        # puts role.properties
        expect(role.properties["users"].size).to eq(2)
      end

      it "should delete specific role" do
        role = FactoryGirl.create(:parse_role)
        
        expect { delete api(roles_path(role)), nil, headers }.to change {ParseRole.count}.by(-1)
        expect(response).to be_success
        expect(json_response).to eq({})
      end

      it "should return correct results for simple list roles query" do
        FactoryGirl.create_list(:parse_role, 5)
        get api(roles_path)
        expect(response).to be_success
        expect(json_response["results"].size).to eq(5)
      end
    end
  end
end