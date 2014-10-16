class AddConfigToParseApplication < ActiveRecord::Migration
  def change
    add_column :parse_applications, :config, :json
  end
end
