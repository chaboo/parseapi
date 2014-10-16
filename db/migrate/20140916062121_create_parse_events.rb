class CreateParseEvents < ActiveRecord::Migration
  def change
    create_table :parse_events do |t|
      t.string :name
      t.hstore :dimensions
      t.hstore :at
      t.integer :parse_application_id

      t.timestamps
    end
  end
end
