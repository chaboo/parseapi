module API
  module APIHelpers
    def attributes_for_keys(keys)
      attrs = {}
      keys.each do |key|
        attrs[key] = params[key] if params[key].present? or (params.has_key?(key) and params[key] == false)
      end
      attrs
    end

    def created_object(object)
      { 
        createdAt: object.created_at,
        objectId: object.obj_id
      }
    end

    def retrieved_object(object)
      atribs = {
        createdAt: object.created_at,
        updatedAt: object.updated_at,
        objectId: object.obj_id
      }
      object.properties.merge(atribs)
    end

    def updated_object(object)
      {
        updatedAt: object.updated_at
      }
    end

    def created_user(user, session_token)
      { 
        createdAt: user.created_at,
        objectId: user.obj_id,
        sessionToken: session_token
      }
    end

    def retrieved_user(user)
      attribs = {
        createdAt: user.created_at.iso8601,
        updatedAt: user.updated_at.iso8601,
        objectId: user.obj_id,
        username: user.username
      }
      user.properties.merge(attribs)
    end

    def logged_user(user, session_token)
      retrieved_user(user).merge(sessionToken: session_token)
    end

    def file_reponse(path)
      {
        url: "#{File.expand_path(File.join("#{path}","#{params[:file_name]}.#{params[:format]}"))}}",
        name: "#{params[:file_name]}"+'.'+"#{params[:format]}"
      }
    end

    def installed_object(object)
      { 
        createdAt: object.created_at,
        objectId: object.obj_id
      }
    end

    def retrieved_installation_object(installation)
      {
        deviceType: installation.device_type,
        deviceToken: installation.device_token,
        channels: installation.channels,
        createdAt: installation.created_at,
        updatedAt: installation.updated_at,
        objectId: installation.obj_id
      }
    end

    def updated_installation_object(installation)
      { updatedAt: installation.updated_at }
    end

    def print_installations(installation_m)
      {
        results:
        Installation.all.each do |installation|
          if installation_m.include?(installation.id)
            retrieved_installation_object(installation)
          end
        end
      }
    end

    def send_notification(message)
      "message '#{message}' "+"sent on channel(s): "
    end

    def parse_object_url(object)
      host = "http://localhost:3000"
      host + parse_object_path(object)
    end

    def parse_object_path(object)
      "/" + API.version + "/classes/" + object.class_name + "/" + object.obj_id
    end

    def parse_file_url(file)
      host = "http://localhost:3000"
      host + parse_file_path(file)
    end

    def parse_file_path(file)
      "/" + API.version + "/files/" + file.name
    end

    def parse_installation_url(object)
      host = "http://localhost:3000"
      host + parse_installation_path(object)
    end

    def parse_installation_path(object)
      "/" + API.version + "/installations/" + object.obj_id
    end

    def parse_user_url(user)
      host = "http://localhost:3000"
      host + parse_user_path(user)
    end

    def parse_user_path(user)
      "/" + API.version + "/users/" + user.obj_id
    end

    def parse_role_url(role)
      host = "http://localhost:3000"
      host + parse_role_path(role)
    end

    def parse_role_path(role)
      "/" + API.version + "/roles/" + role.obj_id
    end

  end
end