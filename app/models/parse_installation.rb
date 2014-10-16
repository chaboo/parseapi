class ParseInstallation < ActiveRecord::Base
	include RQuery

  after_create :set_obj_id, :set_installation_id
  
  belongs_to :parse_application

  serialize :channels
  # TODO: validation
  # properties must not contain objectId, createdAt, updatedAt

  private

  # TODO: Installation seams specific ParseObject with class_name Installation
  def set_obj_id
    hashid = Hashids.new('ideus_salt', 10)
    self.update_attributes(obj_id: hashid.encrypt(self.id))
  end

  def set_installation_id
    hashid = Hashids.new('IdeusInstallation', 10)
    self.update_attributes(installation_id: hashid.encrypt(self.id))
  end

end
