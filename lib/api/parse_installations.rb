module API
  class ParseInstallations < Grape::API
    helpers do
      def create(params)
        installation = ParseInstallation.create(params)
        if installation
          return installation
        else
          raise ParseError.new(107, "")
        end
      end

      def show(obj_id)
        installation = ParseInstallation.find_by(obj_id: obj_id)
        if installation
          return installation
        else
          raise ParseError.new(101,"get")
        end
      end

      def update(params, obj_id)
        installation = ParseInstallation.find_by(obj_id: obj_id)
        if installation
          if installation.update_attributes(params)
            installation
          end
          #TODO case when invalid json
        else
          raise ParseError.new(101, "update")
        end
      end

      def destroy(params)
        installation = ParseInstallation.find_by(obj_id: params[:obj_id])
        if installation
          return installation.destroy
        else
          raise ParseError.new(101, "delete")
        end
      end
    end

    resource :installations do 

      get ':obj_id' do
        installation = show(params[:obj_id])
        retrieved_installation_object(installation)
      end
      
      post do
        installation =  ParseInstallation.create(
                              device_type: params[:deviceType],
                              device_token: params[:deviceToken],
                              channels: params[:channels]
                        )
        header "Location", parse_installation_url(installation)
        installed_object(installation)
      end

      put ':obj_id' do
        ## for invalid json can't catch ActionDispatch::ParamsParser::ParseError
        # TODO: not safe        
        attribs = JSON.parse(request.body.read).slice!(:obj_id, :created_at, :updated_at)
        installation = update(attribs, params[:obj_id])
        updated_installation_object(installation)
      end

      delete ':obj_id' do
        return {} if destroy(obj_id: params[:obj_id])
      end

      # Query installations
      #
      # Parameters:
      #   where (optional) - 
      #
      # Example Request:
      #   GET /1/installations
      #   GET /1/installations?where=
      #
      # Example response:
      # {
      #   "results": [
      #     {
      #       "channels": [
      #         "channel1",
      #         "channel2"
      #       ],
      #       "deviceToken": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      #       "deviceType": "ios",
      #       "createdAt": "2014-09-18T10:30:45.661Z",
      #       "updatedAt": "2014-09-18T11:14:08.651Z",
      #       "objectId": "coX2UoNA5L"
      #     }
      #   ]
      # }
      get do
        if params[:where]
          ParseInstallation.rquery(where: params[:where])
        else
          parse_installations = ParseInstallation.all
          temp_objects = parse_installations.map {|installation| retrieved_installation_object(installation) }
          { results: temp_objects }
        end
      end
      
    end
  end
end