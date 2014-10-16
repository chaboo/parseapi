require 'rails_helper'

describe 'Model#rquery option' do

  it 'should return nil if no rquery arguments' do
    FactoryGirl.create_list(:parse_object, 5)
    results = ParseObject.rquery
    expect(results).to eq({:results=>[]})
  end

  describe 'count' do
    it 'should return correct number of matched objects' do
      FactoryGirl.create_list(:parse_object, 5)
      FactoryGirl.create_list(:parse_object, 2, class_name: "Game")
      results = ParseObject.rquery(:where => "{\"class_name\":\"Game\"}", :count => "1")
      expect(results[:count]).to eq(2)
    end

    it 'should return correct number of matched objects' do
      FactoryGirl.create_list(:parse_object, 3)
      results = ParseObject.rquery(count: "1")
      expect(results[:count]).to eq(3)
    end

    it 'should not return count parameter in the response' do
      FactoryGirl.create(:parse_object)
      results = ParseObject.rquery(count: "0")
      expect(results[:count]).to eq(nil)
    end
  end

  describe 'limit' do
    it 'should return maximum limit number of results' do
      FactoryGirl.create_list(:parse_object, 5)
      results = ParseObject.rquery(limit: "2")
      expect(results[:results].count).to eq(2)
    end
  end

  describe 'order' do
    it 'should order ASC by properties->> name' do
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "C"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "A"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "B"} )
      results = ParseObject.rquery(order: "properties->>'name'")
      expect(results[:results].count).to eq(3)
      expect(results[:results].first.properties["name"]).to eq("A")
      expect(results[:results].last.properties["name"]).to eq("C")
    end

    it 'should order DESC by properties->> name' do
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "A"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "C"} )
      FactoryGirl.create(:parse_object, class_name: "OrderTest", properties: {name: "B"} ) 
      results = ParseObject.rquery(order: "-properties->>'name'")
      expect(results[:results].count).to eq(3)
      expect(results[:results].first.properties["name"]).to eq("C")
      expect(results[:results].last.properties["name"]).to eq("A")
    end

    it 'TODO: test when multiple properties are specified' do
    end

    # is it responsibility of rquery to make sure that property exists
    # or is this the responsibility of the code which parses the request
    #
    it 'TODO: should fail if properties -> name does not exist' do
    end     
  end

  describe 'skip' do
    it 'should skip defined numbers of records' do
      FactoryGirl.create_list(:parse_object, 5, class_name: "SkipTest")
      results = ParseObject.rquery(skip: 2)
      expect(results[:results].count).to eq(3)
    end
  end
end