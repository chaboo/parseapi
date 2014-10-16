class ParseFile < ActiveRecord::Base
  mount_uploader :pfile, FileUploader

  def as_json(options={})
    {url: file_url(pfile.identifier), name: pfile.identifier}
  end

  def name
    pfile.identifier
  end

  def file_url(filename)
    "http://localhost:3000/1/files/" + filename
  end
end
