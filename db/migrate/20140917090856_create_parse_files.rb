class CreateParseFiles < ActiveRecord::Migration
  def change
    create_table :parse_files do |t|
      t.string :pfile
      t.timestamps
    end
  end
end
