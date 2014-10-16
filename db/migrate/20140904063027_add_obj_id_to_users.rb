class AddObjIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :obj_id, :string
  end
end
