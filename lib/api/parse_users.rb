module API
  class ParseUsers < Grape::API
    resource :users do 
      post do
        req_params = JSON.parse(request.body.read)
        # TODO: validate that params[:username] and params[:password] are present
        properties = req_params.except(:username, :password, :email)
        user = ParseUser.create({
                        username: params[:username],
                        email: params[:email], 
                        password: params[:password],
                        properties: properties
                  })

        session_token = ParseUser.sign_in(user)

        header "Location", parse_user_url(user)
        created_user(user, session_token)
      end
    
      get 'me' do
        session_token = headers["X-Parse-Session-Token"]
        # raise error code: 101, error: "invalid session"
        user = ParseUser.authenticate(session_token)
        retrieved_user(user) 
      end

      get ':obj_id' do
        user = ParseUser.find_by(obj_id: params[:obj_id])
        retrieved_user(user)
      end

      put ':obj_id' do
        req_params = JSON.parse(request.body.read)
        # TODO: validate that params[:username] and params[:password] are present
        properties = req_params.except(:username, :password, :email)
        
        user = ParseUser.authenticate(headers["X-Parse-Session-Token"])
        user.update_attributes(properties: user.properties.merge(properties))
        updated_object(user)
      end

      delete ':obj_id' do
        user = ParseUser.authenticate(headers["X-Parse-Session-Token"])
        user.destroy
        {}
      end

      get do
        users = ParseUser.all.map {|u| retrieved_user(u) }
        { results: users }
      end
    end

    resource :login do
      get do
        user = ParseUser.find_by(username: params[:username], password: params[:password])
        session_token = ParseUser.sign_in(user)
        logged_user(user, session_token)
      end
    end

    resource :requestPasswordReset do
      post do
      end
    end
  end
end