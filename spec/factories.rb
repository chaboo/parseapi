FactoryGirl.define do
  factory :parse_object do
    class_name "GameScore"
    sequence(:properties) {|n| { "score" => n, "playerName" => "Sean Plott", "cheatMode" => false }}
  end

  factory :parse_installation do
    device_type "android"
    device_token "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
    channels ["channel1", "channel2"]
  end
  
  factory :parse_application do
  end

  factory :parse_user do
    sequence(:username) { |n| "cooldude_#{n}" }
    sequence(:password) { |n| "something_#{n}" }
    properties { { phone: "123-1444-121"} }
  end

  factory :parse_role do
    class_name "_Role"
    sequence(:properties) {|n| { "name" => "Moderators_#{n}", "ACL"=> {"*"=> {"read" => true }} }}
  end

  factory :parse_event do
    name "MyString"
    dimensions ""
    at ""
  end

  factory :parse_file do
    pfile { Rack::Test::UploadedFile.new(Rails.root + 'spec/fixtures/files/testpic.jpg') }
  end
end