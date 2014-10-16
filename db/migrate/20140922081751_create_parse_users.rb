class CreateParseUsers < ActiveRecord::Migration
  def change
    create_table :parse_users do |t|
      t.string :username
      t.string :password
      t.string :email
      t.string :class_name
      t.string :obj_id
      t.json :properties

      t.timestamps

    end
  end
end
