require 'acts_as_rateable'
ActiveRecord::Base.send(:include, Juixe::Acts::Rateable)
