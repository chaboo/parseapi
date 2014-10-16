require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers
  
  describe "queries with count option" do
    it 'should return an exact count of matched objects' do
      custom_class = "CountTest1"
      custom_count = 5
      FactoryGirl.create_list(:parse_object, custom_count, class_name: custom_class)
      get api(objects_path(custom_class)), count: 1
      expect(json_response["count"]).to eq(custom_count)
    end

    it 'should return a count of 0 when there is no matching objects' do
      get api(objects_path("NonExistingClass")), count: 1
      expect(json_response["count"]).to eq(0)
    end

    it 'should not return count in the response when count option is set to 0' do
      custom_class = "CountTest1"
      FactoryGirl.create_list(:parse_object, 5, class_name: custom_class)
      get api(objects_path(custom_class)), count: 0
      expect(json_response["count"]).to eq(nil)
    end
  end

  describe "queries with limit option" do
    it 'should return maximum limit number of results' do
      FactoryGirl.create_list(:parse_object, 5, class_name: "LimitTest")
      get api(objects_path("LimitTest")), { limit: 2 }
      expect(json_response["results"].count).to eq(2)
    end
  end

  describe "queries with order option" do
    it 'should order ASC by properties ->> name' do
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "C"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "A"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "B"} )
      get api(objects_path("OrderTest")), { order: "properties->>'name'" }
      expect(json_response["results"].first["properties"]["name"]).to eq("A")
      expect(json_response["results"].last["properties"]["name"]).to eq("C")
    end

    it 'should order DESC by properties ->> name' do
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "A"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "C"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "B"} )      
      get api(objects_path("OrderTest")), { order: "-properties->>'name'" }
      expect(json_response["results"].first["properties"]["name"]).to eq("C")
      expect(json_response["results"].last["properties"]["name"]).to eq("A")
    end

    it 'TODO: test when multiple properties are specified' do
    end

    it 'TODO: should fail if properties ->> name does not exist' do
    end
  end

  describe "queries with skip option" do
    it 'should skip defined numbers of records' do
      FactoryGirl.create_list(:parse_object, 5, class_name: "SkipTest")
      get api(objects_path("SkipTest")), { skip: 2 }
      expect(json_response["results"].count).to eq(3)
    end
  end

end