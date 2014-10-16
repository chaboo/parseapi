class ParseRole < ActiveRecord::Base
  after_create :set_obj_id
  # name and ACL are required attributes
  # "roles" and "users" relations are set to default values if they are not provided
  
  private
  
  def set_obj_id
    hashid = Hashids.new('ideus_salt', 10)
    self.update_attributes(obj_id: hashid.encrypt(self.id))
  end

end