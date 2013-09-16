class Flickr
  PRIVACY_PUBLIC = 1
  PRIVACY_PRIVATE = 5
  API_PER_PAGE = 500

  attr_reader :obj
  def initialize current_user
    configs = Devise.omniauth_configs[:flickr].args

    FlickRaw.api_key = configs.first
    FlickRaw.shared_secret = configs.last

    flickr.access_token = current_user.authentications.first.access_token
    flickr.access_secret = current_user.authentications.first.access_secret
    @obj = flickr
  end

  def filter_sets_photos_query sets_photos, query = nil
    return sets_photos.select{|p| /#{query}/ =~ p.title } unless query.nil?
    sets_photos
  end

  def removed_photos set
    UserPhoto.where(user_set_id: set.id).where(is_include_set: false).order('updated_at ASC').all
  end

  def photos_with_modify_record  set, privacy, query
    counts = @obj.photosets.getInfo(photoset_id: set.id).count_photos
    photos = []
    (counts.to_f / self.class::API_PER_PAGE.to_f).ceil.times.each do |page|
      photos << @obj.photosets.getPhotos(photoset_id: set.id, privacy_filter: privacy, page: (page + 1)).photo
    end
    photos = photos.flatten
    user_photos = UserPhoto.where(id: photos.map{|p| p.id}).pluck(:id)

    ActiveRecord::Base.transaction do
      photos.each do |photo|
        unless user_photos.include? photo.id.to_i
          obj = UserPhoto.find_or_initialize_by(id: photo.id)
          obj.is_include_set = true
          obj.user_set = set
          obj.save!
        end
      end
    end
    self.filter_sets_photos_query photos, query
  end

  def remove_photo_by_set set, photo
      self.modify_photo_by_set set, photo, false
  end

  def restore_photo_by_set set, photo
      self.modify_photo_by_set set, photo, true
  end

  def modify_photo_by_set set, photo, is_include_set
    ActiveRecord::Base.transaction do
      if is_include_set
        @obj.photosets.addPhoto(photoset_id: set.id, photo_id: photo.id)
      else
        @obj.photosets.removePhoto(photoset_id: set.id, photo_id: photo.id)
      end
      obj = UserPhoto.find photo.id
      obj.is_include_set = is_include_set
      obj.save!
    end
  end

  def change_privacy photo, privacy
    is_public = 0
    is_family = 0
    is_friend = 0
    perm_comment = 3
    perm_addmeta = 2
    if self.class::PRIVACY_PUBLIC == privacy
      is_public = 1
    end
    @obj.photos.setPerms(photo_id: photo.id, is_public: is_public, is_family: is_family, is_friend: is_friend, perm_comment: perm_comment, perm_addmeta: perm_addmeta)
  end
end
