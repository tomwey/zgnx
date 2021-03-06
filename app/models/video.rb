require 'qiniu'
class Video < ActiveRecord::Base
  # include PgSearch
  # pg_search_scope :search, against: [:title, :body]
  
  validates :title, :file, :cover_image, :category_id, presence: true
  
  belongs_to :user
  belongs_to :category
  
  has_many :likes, dependent: :destroy, as: :likeable
  has_many :favorites, dependent: :destroy, as: :favoriteable
  has_many :view_histories, dependent: :destroy, as: :viewable
  
  # mount_uploader :file, VideoUploader
  mount_uploader :cover_image, CoverImageUploader
  
  scope :sorted, -> { order('sort desc') }
  scope :recent, -> { order('id desc') }
  scope :hot,    -> { order('view_count desc') }
  scope :more_liked, -> { order('likes_count desc') }
  scope :approved, -> { where(approved: true) }
  
  before_create :generate_stream_id
  def generate_stream_id
    self.stream_id = SecureRandom.uuid.gsub('-', '') if self.stream_id.blank?
  end
  
  def type
    2
  end
  
  def file_url
    return '' if self.file.blank?
    origin_file_url = 'http://cdn.yaying.tv' + "/uploads/video/" + self.file
    Qiniu::Auth.authorize_download_url(origin_file_url)
  end
  
  def video_file_url
    file_url
  end
  
  def self.search(keyword)
    where('title like :keyword or body like :keyword', keyword: "%#{keyword}%")
  end
  
  def add_search_count
    self.class.increment_counter(:search_count, self.id)
  end
  
  def approve!
    self.approved = true
    self.save!
  end
  
  def cancel_approve!
    self.approved = false
    self.save!
  end
  
end
