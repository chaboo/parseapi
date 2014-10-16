require 'rails_helper'

describe API::API, api: true do
  include ApiHelpers

  before do
    p1 = ParseObject.create(:class_name => "PostTest")
    ParseObject.create(:class_name => "CommentTest", properties: {"post" => "#{p1.id}" })
    ParseObject.create(:class_name => "GameScore_test", properties: {"game" => 6, "set" => 3, "match" => 1, "name" => "Hipchat"})
    ParseObject.create(:class_name => "GameScore_test", properties: {"game" => 4, "set" => 2, "match" => 1, "name" => "Hipster"})
  end

  after do
    ParseObject.destroy_all
  end

  it "should return a collection of objects" do
    get api(objects_path("GameScore_test")), { where: '{"class_name": "GameScore_test"}' }
    expect(json_response['results'].count).to eq(ParseObject.where(class_name: "GameScore_test").count)
  end

  it "should return two games" do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'game\'":{"$gte":"5"}}' }
    expect(json_response['results'].count).to eq(1)
  end

  it "should return one GameScore" do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'game\'":{"$in":"[\'3\',\'4\']"}}' }
    expect(json_response['results'].count).to eq(1)
  end

  it "should return no object" do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'game\'":{"$in":"[\'1\',\'2\']"}}' }
    expect(json_response['results'].count).to eq(0)
  end

  it "shoul reutrn 2 objects with game NOT IN [1, 2]" do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'game\'":{"$nin":"[\'1\',\'2\']"}}' }
    expect(json_response['results'].count).to eq(2)
  end

  it "shoul reutrn ono game NOT IN [4, 6]" do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'game\'":{"$nin":"[\'4\',\'6\']"}}' }
    expect(json_response).to eq({"results"=>[]})
  end

  it 'should return 2 results where name LIKE Hip%' do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'name\'":{"$like":"Hip%"}}' }
    expect(json_response['results'].count).to eq(2)
  end

  it 'should return no results where name LIKE hip%' do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'name\'":{"$like":"hip%"}}' }
    expect(json_response['results'].count).to eq(0)
  end

  it 'should return 2 results where name ILIKE hip%' do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'name\'":{"$ilike":"hip%"}}' }
    expect(json_response['results'].count).to eq(2)
  end

  it 'should return results where name is Hipster and created_at IS NOT NULL' do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'name\'":"Hipster", "createdAt":{"$exists":true}}'}
    expect(json_response['results'].count).to eq(1)
  end

  it 'should return no results where created_at IS NULL' do
    get api(objects_path("GameScore_test")), { where: '{"createdAt":{"$exists":false}}'}
    expect(json_response).to eq({"results"=>[]})
  end

  it 'should return [{:name => "foo", :description => "bar"}]' do
    get api(objects_path("GameScore_test")), { where: ' {"id":{"$select":{"query":{"className":"GameScore_test","where":{"properties->>\'game\'":{"$gte":"4"}}},"key":"id"}}}'} 
    expect(json_response['results'].count).to eq(2)
  end

  it 'should return 2 records created after 2011' do
    get api(objects_path("GameScore_test")), { where: '{"createdAt":{"$gte":{"__type":"Date","iso":"2011-08-21T18:02:52.249Z"}}}'}
    expect(json_response['results'].count).to eq(2)
  end

  it 'should return no recordsc reated in 2011' do
    get api(objects_path("GameScore_test")), { where: '{"createdAt":{"$eq":{"__type":"Date","iso":"2011-08-21T18:02:52.249Z"}}}'}
    expect(json_response['results'].count).to eq(0)
  end

  it 'should return one object with name Hipchat' do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'name\'":{"$eq":{"__type":"Byte","base64":"SGlwY2hhdA=="}}}'}
    expect(json_response['results'].count).to eq(1)   
  end

  it 'should return no objects with name Milk shake1' do
    get api(objects_path("GameScore_test")), { where: '{"properties->>\'name\'":{"$eq":{"__type":"Byte","base64":"TWlsayBzaGFrZTE"}}}'}
    expect(json_response['results'].count).to eq(0)   
  end

  it 'should return no objects with name like Hip using Base64' do
    get api(objects_path("GameScore_test")), params: { where: '{"properties->>\'name\'":{"$like":{"__type":"Byte","base64":"SGlwJQ=="}}}'}
    expect(json_response['results'].count).to eq(2)   
  end

  it 'should return one record with class_name "CommentTest"' do
    object_id = ParseObject.where(class_name: "PostTest").first.obj_id
    get api(objects_path("CommentTest")), { where: '{"post":{"__type":"Pointer","className":"PostTest","objectId":' + "\"#{object_id}\"" + '}}'}
    expect(json_response['results'].count).to eq(1) 
  end

  it 'should return no records with class_name "CommentTest"' do
    get api(objects_path("CommentTest")), { where: '{"post":{"__type":"Pointer","className":"PostTest","objectId":"IvaNadsX"}}'}
    expect(json_response).to eq({"results"=>[]})
  end

  it 'should return 2 records with game>=4 or name=Hipchat"' do
    get api(objects_path("GameScore_test")), { where: '{"$or":[{"properties->>\'game\'":{"$gte":"4"}},{"properties->>\'name\'":"Hipchat"}]}'}
    expect(json_response['results'].count).to eq(2) 
  end

  it 'test inQuery' do
    get api(objects_path("CommentTest")), { where: '{"post":{"$inQuery":{"where":{"createdAt":{"$exists":true}},"className":"PostTest"}}}'}
    expect(json_response['results'].count).to eq(1) 
  end

  it 'test notInQuery' do
    get api(objects_path("CommentTest")), { where: '{"post":{"$notInQuery":{"where":{"createdAt":{"$exists":true}},"className":"PostTest"}}}'}
    expect(json_response['results'].count).to eq(0) 
  end

  it 'test notInQuery with one result' do
    get api(objects_path("CommentTest")), { where: '{"post":{"$notInQuery":{"where":{"properties ->> \'name\'":{"$eq":"test"}},"className":"PostTest"}}}'}
    expect(json_response['results'].count).to eq(1)
  end
end