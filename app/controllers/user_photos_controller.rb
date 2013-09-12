class UserPhotosController < ApplicationController
  
    before_filter do
  @set = UserSet.find self.photoset_by_photo_id(params[:user_photo][:id])
    @flick = Flickr.new @set.user
  end

  def publish
    @flick.change_privacy UserPhoto.find(params[:user_photo][:id]), Flickr::PRIVACY_PUBLIC
    redirect_to user_set_path(id: self.photoset_by_photo_id(params[:user_photo][:id]))
  end

  def hide
    @flick.change_privacy UserPhoto.find(params[:user_photo][:id]), Flickr::PRIVACY_PRIVATE
    redirect_to user_set_path(id: self.photoset_by_photo_id(params[:user_photo][:id]))
  end

  def remove
    @flick.remove_photo_by_set @set, UserPhoto.find(params[:user_photo][:id])
    redirect_to user_set_path(id: self.photoset_by_photo_id(params[:user_photo][:id]))
  end

  def restore
    @flick.restore_photo_by_set @set, UserPhoto.find(params[:user_photo][:id])
    redirect_to user_set_path(id: self.photoset_by_photo_id(params[:user_photo][:id]))
  end

  protected
  def photoset_by_photo_id id
    UserPhoto.where(id: id).pluck(:user_set_id).first
  end
end
