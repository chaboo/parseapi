class CreateParseRoles < ActiveRecord::Migration
  def change
    create_table :parse_roles do |t|
      t.string :class_name
      t.json :properties
      t.string :obj_id
      
      t.timestamps
    end
  end
end
