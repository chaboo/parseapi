class ParseApplication < ActiveRecord::Base
   has_many :parse_events
   has_many :parse_installations
end
