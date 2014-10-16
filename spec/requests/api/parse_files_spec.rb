require 'rails_helper'
require 'base64'

describe API::API, api: true do
  include ApiHelpers
  
  describe "ParseFiles" do
    it "should create new text file when provided with string data" do
      headers = { CONTENT_TYPE: 'text/plain' }
      filename = "hello.txt"

      post api(files_path(filename)), "Hello, World!", headers
      # expect { post api(files_path(filename)), "Hello, World!", headers }.to change {ParseFile.count}.by(1)
      expect(response).to be_success
      expect(response.header['Location']).to eq("http://localhost:3000/1/files/hello.txt")
      expect(json_response["url"]).to eq("http://localhost:3000/1/files/hello.txt")
      expect(json_response["name"]).to eq("hello.txt")
    end

    it "should create new file when provided with binary data" do
      headers = { CONTENT_TYPE: 'image/jpeg' }
      filename = "testpic.jpg"
      file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/' + filename), 'image/jpeg')

      expect { post api(files_path(filename)), file, headers }.to change {ParseFile.count}.by(1)
      expect(response).to be_success
      expect(response.header['Location']).to eq("http://localhost:3000/1/files/testpic.jpg")
      expect(json_response["url"]).to eq("http://localhost:3000/1/files/testpic.jpg")
      expect(json_response["name"]).to eq("testpic.jpg")
    end

    it "should delete file" do
      parse_file = FactoryGirl.create(:parse_file)
      expect { delete api(files_path(parse_file.name)) }.to change {ParseFile.count}.by(-1)
      expect(response).to be_success
    end
  end
end