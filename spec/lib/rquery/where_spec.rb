require 'rails_helper'

describe 'Model#rquery where' do

  before do    
    ParseObject.create({class_name: "Imlek1", properties: {"barcode" => 12345678, "origin" => "Eritrea", "name" => "Milk shake1"}})
    ParseObject.create({class_name: "Imlek2", properties: {"barcode" => 32145678, "origin" => "Eritrea", "name" => "Milk shake2"}})
    ParseObject.create({class_name: "Imlek3", properties: {"barcode" => 12365678, "origin" => "Eritrea", "name" => "Milk shake3"}})
    ParseObject.create({class_name: "Imlek4", properties: {"barcode" => 29834723, "origin" => "Eritrea", "name" => "Milk shake4"}})
    ParseObject.create({class_name: "Imlek5", properties: {"barcode" => 98347984, "origin" => "Eritrea", "name" => "Milk shake5"}})
    ParseObject.create({class_name: "Imlek6", properties: {"barcode" => 32971321, "origin" => "Eritrea", "name" => "Milk shake6"}})
    ParseObject.create({class_name: "Imlek7", properties: {"barcode" => 32049823, "origin" => "Eritrea", "name" => "Milk shake7"}})
    ParseObject.create({class_name: "Imlek8", properties: {"barcode" => 32948234, "origin" => "Eritrea", "name" => "Milk shake8"}})
    ParseObject.create({class_name: "Imlek9", properties: {"barcode" => 32087094, "origin" => "Eritrea", "name" => "Milk shake9"}})
    ParseObject.create({class_name: "Imlek10", properties: {"barcode" => 32487293, "origin" => "Eritrea", "name" => "Milk shake10"}})
    ParseObject.create({class_name: "Imlek11", properties: {"barcode" => 85349873, "origin" => "Eritrea", "name" => "Milk shake11"}})
    ParseObject.create({class_name: "Imlek12", properties: {"barcode" => 76348223, "origin" => "Eritrea", "name" => "Milk shake12"}})
  end

  after do
    ParseObject.destroy_all
  end

  it 'should return "results":[{class_name: "Imlek1", properties: {"barcode" => 12345678, "origin" => "Eritrea", "name" => "Milk shake1"}}]' do
    results = ParseObject.rquery :where => "{\"class_name\":\"Imlek1\"}"
    expect(results[:results].count).to eq(1)
    expect(results[:results].first.properties["name"]).to eq("Milk shake1")
  end

  it 'should return :results => []' do
    results = ParseObject.rquery :where => "{\"class_name\":\"foo2\"}"
    expect(results).to eq({:results=>[]})
  end

  it 'should return "results":[{class_name: "Imlek1", properties: {"barcode" => 12345678, "origin" => "Eritrea", "name" => "Milk shake1"}}]' do
    results = ParseObject.rquery :where => "{\"class_name\":\"Imlek1\",\"properties->>'name'\":\"Milk shake1\"}"
    expect(results[:results].count).to eq(1)
    expect(results[:results].first.properties["barcode"]).to eq(12345678)
  end

  it 'should return :results" => []' do
    results = ParseObject.rquery :where => "{\"class_name\":\"Ivana\",\"properties->>'name'\":\"Milk shake1\"}"
    expect(results).to eq({:results=>[]})
  end

  it 'should return [{:class_name: "Imlek5"...}]' do
    results = ParseObject.rquery :where => "{\"class_name\":\"Imlek5\",\"properties->>'barcode'\":{\"$gt\":\"12345678\"}}"
    expect(results[:results].count).to eq(1)
  end

  it 'should return :results" => []' do
    results = ParseObject.rquery :where => "{\"class_name\":\"Imlek5\",\"properties->>'barcode'\":{\"$eq\":\"12345678\"}}"
    expect(results).to eq({:results=>[]})
  end

  it 'should return all but Imlek1' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$ne\":\"Imlek1\"}}"
    expect(results[:results].count).to eq(11)
  end

  it 'should return :results" => []' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$eq\":\"Imlek\"}}"
    expect(results).to eq({:results=>[]})
  end

  it 'should return  Imlek12...' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$eq\":\"Imlek12\"}}"
    expect(results[:results].count).to eq(1)
    expect(results[:results].first.properties["barcode"]).to eq(76348223)
  end

  it 'should return [{:class_name => "Imlek1"...}, {:class_name => "Imlek5 ...}]' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$in\":\"['Imlek1','Imlek5']\"}}"
    expect(results[:results].count).to eq(2)
  end

  it 'should return :results" => []' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$in\":\"('foobar')\"}}"
    expect(results).to eq({:results=>[]})
  end

  it 'should return 10 objects whose class_names are not Imlek1 and Imlek2' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$nin\":\"['Imlek1', 'Imlek2']\"}}"
    expect(results[:results].count).to eq(10)
  end

  it 'should return :results" => []' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$nin\":\"['Imlek1','Imlek2', 'Imlek3', 'Imlek4', 'Imlek5', 'Imlek6', 'Imlek7', 'Imlek8', 'Imlek9', 'Imlek10', 'Imlek11', 'Imlek12']\"}}"
    expect(results).to eq({:results=>[]})
  end

  it 'should return all 12 objects because they all have class_name defined' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$exists\":true}}"
    expect(results[:results].count).to eq(12)
  end

  it 'should return :results" => []' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$exists\":false}}"
    expect(results).to eq({:results=>[]})
  end

  it 'should return all 12 objects, name like Imlek%' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$like\":\"Imlek%\"}}"
    expect(results[:results].count).to eq(12)
  end

  it 'should return all 4 objects, name like Imlek1%' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$like\":\"Imlek1%\"}}"
    expect(results[:results].count).to eq(4)
  end

  it 'should return :results" => [], name like f% ' do
    results = ParseObject.rquery :where => "{\"class_name\":{\"$like\":\"f%\"}}"
    expect(results).to eq({:results=>[]})
  end
  
  #select
  it 'should return [{:name => "foo", :description => "bar"}]' do
    results = ParseObject.rquery :where => "{\"id\":{\"$select\":{\"query\":{\"className\":\"Imlek1\",\"where\":{\"properties ->> 'name'\":{\"$like\":\"Milk shake%\"}}},\"key\":\"id\"}}}"
    expect(results[:results].count).to eq(1)
  end

  it 'should return objects where class_name like %5 or name = Milk shake12' do
    results = ParseObject.rquery :where => "{\"$or\":[{\"class_name\":{\"$like\":\"%5\"}},{\"properties ->> 'name'\":\"Milk shake12\"}]}"
    expect(results[:results].count).to eq(2)
  end

end