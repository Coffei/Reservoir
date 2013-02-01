class AddUrlToRoom < ActiveRecord::Migration
  def up
    add_column(:rooms, :cal_url, :string)
  end
  
  def down
    remove_column(:rooms, :cal_url)
  end
end