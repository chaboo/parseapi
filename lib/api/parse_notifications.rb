module API
  class ParseNotifications < Grape::API
    helpers do
      def send_notification(message, installations)
        # puts "Message (" + message["alert"] + ") would be sent to installations: " + installations_ids(installations).to_s
      end

      def installations_ids(installations)
        return installations.map { |i| i.id }
      end

      def validate_push(params)
        if params.keys.include?("where")
          raise ParseError.new(117) if params.keys.include?("channels")
        else
          if params[:channels].present?
            raise ParseError.new(107, "Invalid json: #{params[:channels]}") if !params[:channels].kind_of?(Array)
          else
            raise ParseError.new(115, "channels")
          end
        end
        raise ParseError.new(115, "data") if !params[:data].present?
      end
    end
   
    # params[:channels] or params[:where] must be present in request, but not both
    # params[:data] must be present within the request
    # params[:channels] must be array
    # params[:where][:channels] can be String or Array
    # 
    # response is { "result": true } if request was successfully received and processed
    # response is { "error": "", "code": code } otherwise
    resource :push do
      post do
        validate_push(params)
        if params.keys.include?("where")
          results = ParseInstallation.rquery(where: params[:where].except(:channels).to_json)
          if params[:where].include?(:channels)
            recipients = results[:results].select do |i|
              ! (i.channels & Array(params[:where][:channels])).empty?
            end
          else
            recipients = results[:results]
          end
        else
          recipients = ParseInstallation.all.select { |i| !(i.channels & params[:channels]).empty? }
        end
        # TODO: implement actual message delivery
        send_notification(params[:data][:alert], recipients)
        status(200)
        { result: true, recipients: recipients.map {|r| r.id } }
      end
    end
  end
end