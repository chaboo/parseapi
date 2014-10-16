require 'rails_helper'

describe 'Model#rquery relations' do

  before do
    p1 = ParseObject.create(:class_name => "Post")
    id = p1.id
    ParseObject.create(:class_name => "Comment",properties: {"post" => id})
  end

  after do
    ParseObject.destroy_all
  end

  it 'should return two records with class_names: Post and Comment' do
    results = ParseObject.rquery(:where => "{\"createdAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"2011-08-21T18:02:52.249Z\"}}}")
    expect(ParseObject.count).to eq(2)
    expect(results[:results].count).to eq(2)
  end

  it 'should return :results => [], no objects created in 2011' do
    results = ParseObject.rquery(:where => "{\"createdAt\":{\"$eq\":{\"__type\":\"Date\",\"iso\":\"2011-08-21T18:02:52.249Z\"}}}")
    expect(results).to eq({:results=>[]})
  end

  it 'should return one object with class_name Post' do
    results = ParseObject.rquery(:where => "{\"class_name\":{\"$eq\":{\"__type\":\"Byte\",\"base64\":\"UG9zdA==\"}}}")
    expect(results[:results].count).to eq(1)
  end

  it 'should return :results => [], no object name Ivana' do
    results = ParseObject.rquery(:where => "{\"class_name\":{\"$eq\":{\"__type\":\"Byte\",\"base64\":\"SXZhbmE=\"}}}")
    expect(results).to eq({:results=>[]})
  end

  it 'should return [{:created_at => "...", :class_name => "Comment"}]' do
    object_id = ParseObject.where(class_name: "Post").first.obj_id
    puts "objectId je #{object_id}"
    results = ParseObject.rquery(:where => "{\"post\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"#{object_id}\"}}", :class_name => "Comment")
    puts results
    expect(results[:results].count).to eq(1)
  end

  it 'should return no records' do
    results = ParseObject.rquery(:where => "{\"post\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"hj2vd2gh3\"}}", :class_name => "Comment")
    #expect(results.count).to eq(1)
    expect(results).to eq({:results=>[]})
  end

  it 'should return one object with class_name Post' do
    results = ParseObject.rquery(:where => "{\"class_name\":{\"__type\":\"Byte\",\"base64\":\"UG9zdA==\"}}")
    expect(results[:results].count).to eq(1)
  end

  it 'test inQuery' do
    results = ParseObject.rquery(:where => "{\"post\":{\"$inQuery\":{\"where\":{\"createdAt\":{\"$exists\":true}},\"className\":\"Post\"}}}", :class_name => "Comment")
    expect(results[:results].count).to eq(1)
  end

  it 'test notInQuery' do
    results = ParseObject.rquery(:where => "{\"post\":{\"$notInQuery\":{\"where\":{\"createdAt\":{\"$exists\":true}},\"className\":\"Post\"}}}", :class_name => "Comment")
    expect(results[:results].count).to eq(0)
  end

  it 'test notInQuery with one result' do
    results = ParseObject.rquery(:where => "{\"post\":{\"$notInQuery\":{\"where\":{\"properties->>'name'\":{\"$eq\":\"test\"}},\"className\":\"Post\"}}}", :class_name => "Comment")
    expect(results[:results].count).to eq(1)
  end

  it 'should check related_to query' do
    FactoryGirl.create_list(:parse_object, 5, class_name: "User")  
    user = FactoryGirl.create(:parse_object, class_name: "User")
    post = FactoryGirl.create(:parse_object, class_name: "Post", properties: {"name" => "Post1", "likes" => [1,2, user.obj_id, 4, 5]})
    
    # new
    # results = ParseObject.with_class("User").rquery(:where => "{\"$relatedTo\":{\"object\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"#{post.obj_id}\"},\"key\":\"likes\"}}")
    # old
    # results = User.rquery(:where => "{\"$relatedTo\":{\"object\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"#{post.obj_id}\"},\"key\":\"likes\"}}")
    # 
    # expect(results[:results].count).to eq(1)
    # expect(results[:results].first["objectId"]).to eq(user.obj_id)
  end

end