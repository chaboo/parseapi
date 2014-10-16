require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "ParseUsers" do
    describe "users" do
      it "should create a new user" do
        headers = { "CONTENT_TYPE" => 'application/json' }
        properties = { username: "cooldude", password: "something", phone: "069331123" }
        expect { post api(users_path), properties.to_json, headers }.to change {ParseUser.count}.by(1)

        expect(response.status).to eq(201)
        expect(response.header["Location"]).to eq("http://localhost:3000/1/users/#{json_response["objectId"]}")
        
        expect(json_response["objectId"]).not_to eq(nil)
        expect(json_response["createdAt"]).not_to eq(nil)
        expect(json_response["sessionToken"]).not_to eq(nil)
      end

      it "should retrieve specific user" do
        user = FactoryGirl.create(:parse_user, properties: {phone: "12345"} )
        get api(users_path(user))
        expect(response).to be_success
        
        expect(json_response["username"]).to eq(user.username)
        expect(json_response["createdAt"]).to eq(user.created_at.iso8601)
        expect(json_response["updatedAt"]).to eq(user.updated_at.iso8601)
        expect(json_response["objectId"]).to eq(user.obj_id)
        expect(json_response["phone"]).to eq(user.properties["phone"])
      end

      it "should retrieve current user" do
        user = FactoryGirl.create(:parse_user, properties: {phone: "12345"} )
        get api(login_path), { username: user.username, password: user.password}

        headers = { "X-Parse-Session-Token" => json_response["sessionToken"]}
        get api(current_user_path), nil, headers
        expect(response).to be_success
        
        expect(json_response["username"]).to eq(user.username)
        expect(json_response["createdAt"]).to eq(user.created_at.iso8601)
        expect(json_response["updatedAt"]).to eq(user.updated_at.iso8601)
        expect(json_response["objectId"]).to eq(user.obj_id)
        expect(json_response["phone"]).to eq(user.properties["phone"])
      end

      # it "should fail in case when sessionToken is incorrect" do
      #   headers = { "X-Parse-Session-Token" => "someincorrecttoken"}
      #   get api(current_user_path), nil, headers
      #   expect(response.status).to eq(404)
      #   expect(json_response['code']).to eq(101)
      #   expect(json_response['error']).to eq("invalid session")
      # end
      
      it "should update specific user" do
        user = FactoryGirl.create(:parse_user, properties: {phone: "12345", custom: "something"} )
        get api(login_path), { username: user.username, password: user.password}

        headers = {
          "X-Parse-Session-Token" => json_response["sessionToken"],
          "CONTENT_TYPE" => "application/json"
        }
        upd = { phone: "21121", address: "New York" }
        put api(users_path(user)), upd.to_json, headers
        expect(response).to be_success
        expect(json_response["updatedAt"]).not_to eq(nil)

        user.reload
        expect(user.properties["phone"]).to eq("21121")
        expect(user.properties["address"]).to eq("New York")
        expect(user.properties["custom"]).to eq("something")
      end

      it "should delete specific user" do
        user = FactoryGirl.create(:parse_user)
        get api(login_path), { username: user.username, password: user.password}
        headers = { "X-Parse-Session-Token" => json_response["sessionToken"] }
        
        expect { delete api(users_path(user)), nil, headers }.to change {ParseUser.count}.by(-1)
        expect(response).to be_success
        expect(json_response).to eq({})
      end

      it "should return correct results for simple list users query" do
        FactoryGirl.create_list(:parse_user, 5)
        get api(users_path)
        expect(response).to be_success
        expect(json_response["results"].size).to eq(5)
      end
    end

    describe "login" do
      it "should sign in user" do
        user = FactoryGirl.create(:parse_user, properties: {phone: "12345"} )
        get api(login_path), { username: user.username, password: user.password}
        expect(response).to be_success
        
        expect(json_response["username"]).to eq(user.username)
        expect(json_response["createdAt"]).to eq(user.created_at.iso8601)
        expect(json_response["updatedAt"]).to eq(user.updated_at.iso8601)
        expect(json_response["objectId"]).to eq(user.obj_id)
        expect(json_response["phone"]).to eq(user.properties["phone"])
        
        expect(json_response["sessionToken"]).not_to eq(nil)
      end
    end
  end
end