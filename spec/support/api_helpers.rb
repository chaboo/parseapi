module ApiHelpers
  # Public: Prepend a request path with the path to the API
  #
  # path - Path to append
  # user - User object - If provided, automatically appends private_token query
  #          string for authenticated requests
  #
  # Examples
  #
  #   >> api('/issues')
  #   => "/api/v2/issues"
  #
  #   >> api('/issues', User.last)
  #   => "/api/v2/issues?private_token=..."
  #
  #   >> api('/issues?foo=bar', User.last)
  #   => "/api/v2/issues?foo=bar&private_token=..."
  #
  # Returns the relative path to the requested API resource
  def api(path, user = nil)
    "/#{API::API.version}#{path}"
  end

  def json_response
    JSON.parse(response.body)
  end

  def objects_path(object)
    return "/classes/#{object.class_name}/#{object.obj_id}" if object.respond_to?(:obj_id) 
    return "/classes/" + object.class_name if object.respond_to?(:class_name)
    return "/classes/" + object
  end

  def batch_path
    '/batch'
  end

  def files_path(filename = nil)
    return '/files/' + filename if filename
    return '/files'
  end

  def installations_path(installation = nil)
    return '/installations/' + installation.obj_id if installation     
    return '/installations'
  end

  def notifications_path
    return '/push'
  end

  def events_path(eventname = nil)
    return '/events/' + eventname if eventname
    return '/events'
  end

  def users_path(user = nil)
    return '/users/' + user.obj_id if user
    return '/users'
  end

  def current_user_path
    return '/users/me'
  end

  def login_path
    return '/login'
  end

  def roles_path(role = nil)
    return '/roles/' + role.obj_id if role
    return '/roles'
  end

  def config_path
    return '/config/'
  end

end
