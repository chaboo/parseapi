module API
  class ParseRoles < Grape::API
    resource :roles do 
      post do
        req_params = JSON.parse(request.body.read)
        # TODO: validate that params[:name] and params[:ACL] are present
        role = ParseRole.create({
                        class_name: "_Role",
                        properties: req_params
                  })

        header "Location", parse_role_url(role)
        created_object(role)
      end
      
      get ':obj_id' do
        role = ParseRole.find_by(obj_id: params[:obj_id])
        retrieved_object(role)
      end

      put ':obj_id' do
        req_params = JSON.parse(request.body.read)
        # TODO: validate that params[:name] is not present
        role = ParseRole.find_by(obj_id: params[:obj_id])
        properties = {}
        req_params.each do |key, value|
          if value.respond_to?(:has_key?) && value.has_key?("__op")
            if key == "users" && value["__op"] == "AddRelation"
              properties["users"] = value["objects"]
            elsif key == "roles" && value["__op"] == "AddRelation"
              properties["roles"] = value["objects"]
            else
              puts "users and roles with AddRelation op type and objects"
              # when without objects
              # raise 
              # {
              #   "code": 111,
              #   "error": "relation operations take array arguments, got a NilClass instead"
              # } 
            end
          elsif key == "name"
            puts "Name should not change"
            # raise code: 136, error: "Cannot change a role's name."
          else
            properties[key] = value
          end
        end
        role.update_attributes(properties: properties)
        updated_object(role)
      end

      delete ':obj_id' do
        role = ParseRole.find_by(obj_id: params[:obj_id])
        role.destroy
        {}      
      end

      get do
        roles = ParseRole.all.map {|u| retrieved_object(u) }
        { results: roles }
      end
    end
  end
end