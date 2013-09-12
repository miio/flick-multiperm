class UserSetsController < ApplicationController

  def index
    @user_sets = UserSet.all
  end

  def new
    flick = Flickr.new current_user
    @sets = flick.obj.photosets.getList.to_a
  end

  def create
    UserSet.create! user_set_params
  end

  def show
    set = UserSet.find params[:id]
    flick = Flickr.new set.user
    @public_photos = flick.photos_with_modify_record set, Flickr::PRIVACY_PUBLIC, params.require(:search).permit(:q)[:q]
    @private_photos = flick.photos_with_modify_record set, Flickr::PRIVACY_PRIVATE, params.require(:search).permit(:q)[:q]
    @removed_photos = flick.removed_photos set
    @q = params.require(:search).permit(:q)[:q]
    
  end

  private
  def user_set_params
    param = params.require(:user_set).permit(:id, :title)
    param[:user] = current_user
    param
  end

end
