class CreateUserSets < ActiveRecord::Migration
  def change
    create_table :user_sets do |t|
      t.references :user, index: true
      t.string :title
      t.timestamps
    end
  end
end
