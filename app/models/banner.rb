class Banner < ActiveRecord::Base
  validates :image, presence: true
  mount_uploader :image, BannerImageUploader
  
  belongs_to :category
  
  scope :sorted, -> { order('sort desc') }
  scope :recent, -> { order('id desc') }
end
