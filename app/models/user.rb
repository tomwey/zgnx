class User < ActiveRecord::Base  
  has_secure_password
  
  attr_accessor :money
  
  validates :mobile, :password, :password_confirmation, presence: true, on: :create
  validates :mobile, format: { with: /\A1[3|4|5|7|8][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, length: { is: 11 }, :uniqueness => true
            
  mount_uploader :avatar, AvatarUploader
  
  has_many :likes, dependent: :destroy
  has_many :liked_videos, through: :likes, source: :likeable, source_type: 'Video'
  
  has_many :favorites, dependent: :destroy
  has_many :favorited_videos, through: :favorites, source: :favoriteable, source_type: 'Video'
  
  has_many :view_histories, dependent: :destroy
  has_many :viewed_videos, through: :view_histories, source: :viewable, source_type: 'Video'
  has_many :viewed_live_videos, through: :view_histories, source: :viewable, source_type: 'LiveVideo'
  
  # has_many :grantings, class_name: 'Grant', foreign_key: 'from'
  # has_many :granteds,  class_name: 'Grant', foreign_key: 'to'
  
  scope :no_delete, -> { where(visible: true) }
  scope :verified,  -> { where(verified: true) }
  
  def hack_mobile
    return "" if self.mobile.blank?
    hack_mobile = String.new(self.mobile)
    hack_mobile[3..6] = "****"
    hack_mobile
  end
  
  # 生成token
  before_create :generate_private_token
  def generate_private_token
    self.private_token = SecureRandom.uuid.gsub('-', '') if self.private_token.blank?
  end
  
  # 禁用账户
  def block!
    self.verified = false
    self.save!
  end
  
  # 启用账户
  def unblock!
    self.verified = true
    self.save!
  end
  
  # 是否已经like
  def liked?(likeable)
    return false if likeable.blank?
    count = likes.where(likeable_type: likeable.class, likeable_id: likeable.id).count
    count > 0
  end
  
  # like
  def like!(likeable)
    return false if likeable.blank?
    Like.create!(user_id: self.id, likeable_id: likeable.id, likeable_type: likeable.class)
  end
  
  # cancel like
  def cancel_like!(likeable)
    return false if likeable.blank?
    like = likes.where(likeable_type: likeable.class, likeable_id: likeable.id).first
    return false if like.blank?
    like.destroy
  end
  
  # 是否已经收藏
  def favorited?(favoriteable)
    return false if favoriteable.blank?
    count = favorites.where(favoriteable_type: favoriteable.class, favoriteable_id: favoriteable.id).count
    count > 0
  end
  
  # 收藏
  def favorite!(favoriteable)
    return false if favoriteable.blank?
    Favorite.create!(user_id: self.id, favoriteable_id: favoriteable.id, favoriteable_type: favoriteable.class)
  end
  
  # 取消收藏
  def cancel_favorite!(favoriteable)
    return false if favoriteable.blank?
    favorite = favorites.where(favoriteable_type: favoriteable.class, favoriteable_id: favoriteable.id).first
    return false if favorite.blank?
    favorite.destroy
  end
  
  # 设置支付密码
  # def pay_password=(password)
  #   self.pay_password_digest = BCrypt::Password.create(password) if self.pay_password_digest.blank?
  # end
  
  # 更新支付密码
  def update_pay_password!(password)
    return false if password.blank?
    self.pay_password_digest = BCrypt::Password.create(password)
    self.save!
  end
  
  # 检查支付密码是否正确
  def is_pay_password?(password)
    return false if self.pay_password_digest.blank?
    BCrypt::Password.new(self.pay_password_digest) == password
  end
  
  def grant_money!(money)
    self.balance += money
    if money > 0
      # 表示收到打赏
      self.receipt_money += money
    else
      # 表示打赏别人
      self.sent_money += -money
    end
    self.save!
  end
  
end
