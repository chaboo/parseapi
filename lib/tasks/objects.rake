namespace :parse do
  task populate_objects: :environment do
    ParseObject.destroy_all
    ParseObject.create({class_name: "Imlek1", obj_id:"hj2vd2gh3", properties: {"barcode" => 12345678, "origin" => "Eritrea", "name" => "Milk shake1"}})
    ParseObject.create({class_name: "Imlek2", obj_id:"abcdabcd", properties: {"barcode" => 32145678, "origin" => "Eritrea", "name" => "Milk shake2"}})
    ParseObject.create({class_name: "Imlek3", obj_id:"flksdjfl", properties: {"barcode" => 12365678, "origin" => "Eritrea", "name" => "Milk shake3"}})
    ParseObject.create({class_name: "Imlek4", obj_id:"312j3hk1", properties: {"barcode" => 29834723, "origin" => "Eritrea", "name" => "Milk shake4"}})
    ParseObject.create({class_name: "Imlek5", obj_id:"32o4j2l3", properties: {"barcode" => 98347984, "origin" => "Eritrea", "name" => "Milk shake5"}})
    ParseObject.create({class_name: "Imlek6", obj_id:"3l24hj2k", properties: {"barcode" => 32971321, "origin" => "Eritrea", "name" => "Milk shake6"}})
    ParseObject.create({class_name: "Imlek7", obj_id:"l54n6kl5", properties: {"barcode" => 32049823, "origin" => "Eritrea", "name" => "Milk shake7"}})
    ParseObject.create({class_name: "Imlek8", obj_id:"km345kj3", properties: {"barcode" => 32948234, "origin" => "Eritrea", "name" => "Milk shake8"}})
    ParseObject.create({class_name: "Imlek9", obj_id:"kl23h42k", properties: {"barcode" => 32087094, "origin" => "Eritrea", "name" => "Milk shake9"}})
    ParseObject.create({class_name: "Imlek10", obj_id:"kj23h4k6", properties: {"barcode" => 32487293, "origin" => "Eritrea", "name" => "Milk shake10"}})
    ParseObject.create({class_name: "Imlek11", obj_id:"432l4kj3", properties: {"barcode" => 85349873, "origin" => "Eritrea", "name" => "Milk shake11"}})
    ParseObject.create({class_name: "Imlek12", obj_id:"45lh6j4k", 
      properties: {
        "barcode" => 1111, 
        "origin" => "Eritrea", 
        "name" => "Milk shake12",
        "user" => {
          "__type" => "Pointer",
          "classname" => "_User",
          "objectId" => "1231"
        },
        "likes" => [
          {
            "__type" => "Pointer",
            "classname" => "_User",
            "objectId" => "1231"
          },
          {
            "__type" => "Pointer",
            "classname" => "_User",
            "objectId" => "1232"
          },
          {
            "__type" => "Pointer",
            "classname" => "_User",
            "objectId" => "1233"
          },
          {
            "__type" => "Pointer",
            "classname" => "_User",
            "objectId" => "1234"
          }
        ]
      }
    })
  end
end