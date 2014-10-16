module API
  class ParseEvents < Grape::API
    helpers do
      def parse_at_attribute(at_attribute)
        if params[:at][:__type] == "Date"
          return params[:at][:iso].to_time.utc.to_s
        end
        # raise ParseApiError
      end
    end

    # TODO 1: 
    # it fails only in case of invalid JSON
    # SO how they handle improperly formated datatypes e.g. at attribute
    # TODO 2:
    # event must belong to specific application (authentication required)
    resource :events do
      post ':event_name' do
        JSON.parse(request.body.read)   # throws JSON::ParserError in case of invalid JSON
        at_time = Time.now.utc.to_s
        at_time = parse_at_attribute(params["at"]) if params.has_key?(:at)
        ParseEvent.create(name: params[:event_name], dimensions: params[:dimensions], at: { iso: at_time })
        {}
      end
    end
  end
end