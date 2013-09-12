class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :provider
      t.references :user, index: true
      t.string :uid
      t.string :provider
      t.string :name
      t.string :access_token
      t.string :access_secret

      t.timestamps
    end
  end
end
