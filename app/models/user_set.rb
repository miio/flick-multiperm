class UserSet < ActiveRecord::Base
  belongs_to :user, foreign_key: "user_id"
		before_create do |record|
		 flick = Flickr.new set.user
    public_photos = flick.obj.photosets.getPhotos(photoset_id: set.id, privacy_filter: Flickr::PRIVACY_PUBLIC).photo
    private_photos = flick.obj.photosets.getPhotos(photoset_id: set.id, privacy_filter: Flickr::PRIVACY_PRICVATE).photo


	end
end
