module API
  class ParseApplications < Grape::API

    # TODO 1: 
    # it fails only in case of invalid JSON
    # SO how they handle improperly formated datatypes e.g. at attribute
    # TODO 2:
    # event must belong to specific application (authentication required)
    resource :config do
      get  do
        object = ParseApplication.first
        results = object.config ? {params:  object.config} : {params: {}}
      end
    end
  end
end