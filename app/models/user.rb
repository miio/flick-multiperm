class User < ActiveRecord::Base
  has_many :authentications
  devise :trackable, :omniauthable

  def set_for_flickr omniauth
    User.transaction do
      lock_obj = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'], lock: true)
      if lock_obj.nil?
        self.authentications.build self.get_flickr_args(omniauth)
      else
        lock_obj.update_attributes self.get_flickr_args(omniauth)
      end
      self.save!
    end
  end

  def get_flickr_args omniauth
    {
      uid: omniauth['uid'],
      provider: omniauth['provider'],
      name: omniauth['info']['name'],
      access_token: omniauth['credentials']['token'],
      access_secret: omniauth['credentials']['secret'],
    }
  end
end
