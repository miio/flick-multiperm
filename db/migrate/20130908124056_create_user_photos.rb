class CreateUserPhotos < ActiveRecord::Migration
  def change
    create_table :user_photos do |t|
      t.references :user_set, index: true
      t.boolean :is_include_set

      t.timestamps
    end
  end
end
