class CreateParseInstallations < ActiveRecord::Migration
  def change
    create_table :parse_installations do |t|
      t.string :device_type
      t.string :obj_id
      t.string :installation_id
      t.string :device_token
      t.text :channels
      t.integer :parse_application_id

      t.timestamps
    end
  end
end
