require 'elasticsearch/model'

class ParseObject < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  include RQuery

  validates :class_name, presence: true

  after_create :set_obj_id
  
  # TODO: validation
  # properties must not contain objectId, createdAt, updatedAt

  def as_indexed_json(options = {}) 
    # self.as_json(options.merge(root: false)) 
    properties.merge({objectId: obj_id, createdAt: created_at, updated_at: updated_at, id: id})
  end

  private

  def set_obj_id
    hashid = Hashids.new('ideus_salt', 10)
    self.update_attributes(obj_id: hashid.encrypt(self.id))
  end

end
