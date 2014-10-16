module API
  class ParseObjects < Grape::API
    helpers do
      def show(params)
        object = ParseObject.find_by(class_name: params[:class_name], obj_id: params[:obj_id])
        if object
          return object
        else
          raise ParseError.new(101, "get")
        end
      end
   
      def create(params)
        object = ParseObject.create!(params)
        if object
          return object
        else
          # raise ParseApiError
          # e.g.
          # ParseApiError({ code: 105, message: "createdAt is a reserved word" })
        end
      end

      def update(params)
        object = ParseObject.find_by(class_name: params[:class_name], obj_id: params[:obj_id])
        if object 
          object.update_attributes(:properties => params[:properties])
        else
          raise ParseError.new(101, "update")
        end
        object
      end

      def destroy(params)
        object = ParseObject.find_by(params)
        if object 
          return object.destroy
        else
          raise ParseError.new(101, "delete")
        end
      end
    end
    
    resource :classes do

      get ':class_name/:obj_id' do
        object = show(class_name: params[:class_name], obj_id: params[:obj_id])
        retrieved_object(object)
      end

      post ':class_name' do
        object = create(class_name: params[:class_name], properties: JSON.parse(request.body.read))
        header "Location", parse_object_url(object)
        created_object(object)
      end

      put ':class_name/:obj_id' do
        object = update(
                  class_name: params[:class_name], 
                  obj_id: params[:obj_id], 
                  properties: JSON.parse(request.body.read)
                )
        updated_object(object)
      end

      delete ':class_name/:obj_id' do
        return {} if destroy(class_name: params[:class_name], obj_id: params[:obj_id])
      end

      get ':class_name' do
        if (params[:where] || params[:order] || params[:limit] || params[:skip] || params[:count])
          if (params.to_s.include?("$select") || params.to_s.include?("Pointer") ||
            params.to_s.include?("$inQuery") || params.to_s.include?("$notInQuery"))
            ParseObject.rquery(params)
          else
            ParseObject.where(class_name: params[:class_name]).rquery(params)
          end
        else
          parse_objects = ParseObject.where(class_name: params[:class_name]).all
          temp_objects = parse_objects.map {|object| retrieved_object(object) }
          { results: temp_objects }
        end
      end   
    end

    # this needs to be executed in single transaction if single request fails
    # nothing should be committed in the database
    resource :batch do
      post do 
        results = []
        prms = JSON.parse(request.body.read)
        prms["requests"].each do |r|
          pars = {}
          case r["method"]
          when "POST"
            pars[:class_name] = r["path"].split("/").last
            pars[:properties] = r["body"]
            object = create(pars)
            results << { success: created_object(object) }

          when "PUT"
            pars[:obj_id] = r["path"].split("/")[-1]
            pars[:class_name] = r["path"].split("/")[-2]
            pars[:properties] = r["body"]
            object = update(pars)
            results << { success: updated_object(object) }

          when "DELETE"
            pars[:obj_id] = r["path"].split("/")[-1]
            pars[:class_name] = r["path"].split("/")[-2]
            if destroy(pars)
              results << { success: true }
            end

          else
            # raise ParseApiError(code: 107, message: "Method 'GET' is not supported in batch operations")
            "Not a valid HTTP request"
          end
        end
        results
      end
    end
  end
end