Dir["#{Rails.root}/lib/api/*.rb"].each {|file| require file}

module API
  class API < Grape::API
    version '1', using: :path

    rescue_from ActiveRecord::RecordNotFound do
      rack_response({'message' => '404 Not found'}.to_json, 404)
    end

    rescue_from ActiveRecord::RecordInvalid do
      rack_response({"message" => "Validation failed: ClassName can't be blank"}.to_json, 400)
    end

    rescue_from ParseError do |exception|
      rack_response({"code" => exception.code, "error" => exception.error}.to_json, 400)
    end

    rescue_from JSON::ParserError do
      rack_response({ 'code'=> 107, 'error' => 'invalid JSON'}.to_json, 400)
    end

    rescue_from :all do |exception|
      # lifted from https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L60
      # why is this not wrapped in something reusable?
      trace = exception.backtrace

      message = "\n#{exception.class} (#{exception.message}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << "  " << trace.join("\n  ")

      API.logger.add Logger::FATAL, message
      rack_response({'message' => '500 Internal Server Error'}, 500)
    end

    format :json
    content_type :txt, "text/plain"
    content_type :binary, "image/jpeg"
    
    helpers APIHelpers

    mount ParseUsers
    mount ParseRoles
    mount ParseObjects
    mount ParseFiles
    mount ParseInstallations
    mount ParseNotifications
    mount ParseEvents
    mount ParseApplications
  end
end