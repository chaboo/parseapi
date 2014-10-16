class ParseUser < ActiveRecord::Base
  after_create :set_obj_id

  def self.sign_in(user)
    return user.id.to_s + "_" + user.obj_id
  end

  def self.authenticate(session_token)
    id, obj_id = session_token.split("_")
    return ParseUser.find_by(obj_id: obj_id)
  end

  private
  
  def set_obj_id
    hashid = Hashids.new('ideus_salt', 10)
    self.update_attributes(obj_id: hashid.encrypt(self.id))
  end


end