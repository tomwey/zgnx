class Video < ActiveRecord::Base
  # include PgSearch
  # pg_search_scope :search, against: [:title, :body]
  
  validates :title, :file, :cover_image, :category_id, presence: true
  
  belongs_to :user
  belongs_to :category
  has_many :likes, as: :likeable
  
  mount_uploader :file, VideoUploader
  mount_uploader :cover_image, CoverImageUploader
  
  scope :sorted, -> { order('sort desc') }
  scope :recent, -> { order('id desc') }
  scope :hot,    -> { order('view_count desc') }
  scope :more_liked, -> { order('likes_count desc') }
  
  before_create :generate_stream_id
  def generate_stream_id
    self.stream_id = SecureRandom.uuid.gsub('-', '') if self.stream_id.blank?
  end
  
  def type
    2
  end
  
  def self.search(keyword)
    where('title like :keyword or body like :keyword', keyword: "%#{keyword}%")
  end
end
