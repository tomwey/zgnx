ActiveAdmin.register LiveVideo do

menu priority: 4, label: '直播'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :cover_image, :body, :video_file, :likes_count, :view_count #:stream_id
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column('#', id) { |live_video| link_to live_video.id, admin_live_video_path(live_video) }
  column '直播封面图', sortable: false do |live_video|
    if live_video.cover_image.blank?
      ''
    else
      image_tag live_video.cover_image.url(:small)
    end
  end
  column(:title, sortable: false) 
  column '直播录制文件', sortable: false do |live_video|
    if live_video.video_file.blank?
      ''
    else
      raw("
      <video height=\"120\" controls >
        <source src=\"#{live_video.video_file_url}\" type=\"video/mp4\">
        Your browser doesn't support HTML5 video tag.
      </video>")
    end
  end
  column '直播流ID', sortable: false do |lv|
    lv.stream_id
  end
  column '人数统计' do |lv|
    if lv.state.to_sym == :closed or lv.video_file.present?
      # 热门的直播
      raw("直播结束 => <br>围观人数：#{lv.view_count}<br>弹幕数：#{lv.msg_count}<br>点赞数：#{lv.likes_count}")
    elsif lv.state.to_sym == :living and lv.video_file.blank?
      # 正在直播
      raw("正在直播 => <br>在线人数：#{lv.online_users_count}<br>弹幕数：#{lv.msg_count}<br>点赞数：#{lv.likes_count}")
    else
      # 直播还未开始
      '直播还未开始'
    end 
  end
  column '直播相关', columns: 3, sortable: false do |live_video|
    raw("RTMP推流地址：#{live_video.rtmp_push_url}<br>
         RTMP直播地址：#{live_video.rtmp_url}<br>
         HLS直播地址： #{live_video.hls_url}")
  end
  
  column '直播状态', sortable: false do |live_video|
    live_video.try(:state_info)
  end
  
  actions defaults: false do |channel|
    if channel.can_live?
      item '开始直播', open_admin_live_video_path(channel), method: :put
    elsif channel.can_close?
      item '关闭直播', close_admin_live_video_path(channel), method: :put
    end
    item " 编辑", edit_admin_live_video_path(channel)
  end
  # actions defaults: false do |product|
  #   item "编辑", edit_admin_product_path(product)
  #   if product.on_sale
  #     item "下架", unsale_admin_product_path(product), method: :put
  #   else
  #     item "上架", sale_admin_product_path(product), method: :put
  #   end
  # end
  
end

# 批量开启
batch_action :open do |ids|
  batch_action_collection.find(ids).each do |channel|
    channel.open!
  end
  redirect_to collection_path, alert: '开启成功'
end

# 批量关闭
batch_action :close do |ids|
  batch_action_collection.find(ids).each do |channel|
    channel.close!
  end
  redirect_to collection_path, alert: '关闭成功'
end

member_action :open, method: :put do
  resource.open!
  redirect_to collection_path, notice: "已开启"
end

member_action :close, method: :put do
  resource.close!
  redirect_to collection_path, notice: "已关闭"
end

show do |live_video|
  h3 live_video.title
  div raw(live_video.body)
  br
  unless live_video.video_file.blank?
    div do
      raw("
      <video width=\"640\" controls >
        <source src=\"#{live_video.video_file_url}\" type=\"video/mp4\">
        Your browser doesn't support HTML5 video tag.
      </video>")
    end
  end
  
end

# form html: { multipart: true } do |f|
#   f.semantic_errors
#   
#   f.inputs do
#     f.input :title
#     f.input :body
#     f.input :lived_at, as: :string, placeholder: '格式为：2016-01-01 14:30:00'
#     f.input :live_address
#     f.input :images, as: :file, input_html: { multiple: true }
#   end
#   
#   actions
# end
form partial: 'form'

end
