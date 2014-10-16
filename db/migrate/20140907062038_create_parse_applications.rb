class CreateParseApplications < ActiveRecord::Migration
  def change
    create_table :parse_applications do |t|

      t.timestamps
    end
  end
end
