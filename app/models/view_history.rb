class ViewHistory < ActiveRecord::Base
  belongs_to :viewable, polymorphic: true
  belongs_to :user
end
