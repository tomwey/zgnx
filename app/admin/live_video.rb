ActiveAdmin.register LiveVideo do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :body, :lived_at, :live_address, { images: [] }, :rtmp_push_url, :rtmp_pull_url, :hls_pull_url
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
  column :id
  column(:title, sortable: false) 
  column :body, sortable: false
  column :lived_at
  column :live_address
  column '活动图片', sortable: false do |live_video|
    ul do
      live_video.images.each do |image|
        li do
          image_tag(image.url(:small), size: '120x74')
        end
      end
    end
  end
  column '直播相关', sortable: false do |live_video|
    raw("RTMP推流地址：#{live_video.rtmp_push_url}<br>RTMP直播地址：#{live_video.rtmp_pull_url}<br>HLS直播地址：#{live_video.hls_pull_url}")
  end
  
  column '直播是否开启', sortable: false do |live_video|
    live_video.closed ? "关闭" : "开启"
  end
  
  actions
  # actions defaults: false do |product|
  #   item "编辑", edit_admin_product_path(product)
  #   if product.on_sale
  #     item "下架", unsale_admin_product_path(product), method: :put
  #   else
  #     item "上架", sale_admin_product_path(product), method: :put
  #   end
  # end
  
end

form html: { multipart: true } do |f|
  f.semantic_errors
  
  f.inputs do
    f.input :title
    f.input :body
    f.input :lived_at, as: :string, placeholder: '格式为：2016-01-01 14:30:00'
    f.input :live_address
    f.input :images, as: :file, input_html: { multiple: true }
  end
  
  actions
end

end