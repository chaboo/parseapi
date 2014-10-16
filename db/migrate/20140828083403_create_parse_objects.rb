class CreateParseObjects < ActiveRecord::Migration
  def change
    create_table :parse_objects do |t|
      t.string :class_name
      t.json :properties
      t.string :obj_id

      t.timestamps
    end
  end
end
